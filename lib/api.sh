#!/usr/bin/env bash
# Os fragmentos são gravados diretamente para preservar quebras de linha.
chat_stream() {
  local sys="$1" user="$2" hist="$3" body rc response done_file fragment curl_cfg
  LAST_RESPONSE_FILE=''
  need_key || return 1
  if [[ ${QUOTA_LIMIT:-0} =~ ^[0-9]+$ ]] && [ "$QUOTA_LIMIT" -gt 0 ] && [ "$(quota_left)" -le 0 ]; then
    echo "Trava local esgotada hoje ($(quota_used)/$QUOTA_LIMIT). O servidor OpenRouter ainda pode impor os seus próprios limites."; return 1
  fi
  jq -e 'type == "array"' "$hist" >/dev/null 2>&1 || { echo "Histórico inválido."; return 1; }
  body=$(jq -n --arg m "$MODEL" --arg s "$sys" --arg u "$user" \
    --argjson t "$TEMPERATURE" --argjson p "$TOP_P" --argjson mt "$MAX_TOKENS" \
    --arg r "$REASONING" --argjson rb "$REASONING_BUDGET" --slurpfile h "$hist" '
      {model:$m,stream:true,temperature:$t,top_p:$p,max_tokens:$mt,
       messages:((if $s=="" then [] else [{role:"system",content:$s}] end)+$h[0]+[{role:"user",content:$u}])}
      + (if $r=="off" then {reasoning:{enabled:false}}
         elif $r=="budget" then {reasoning:{enabled:true,max_tokens:$rb}}
         else {reasoning:{enabled:true,effort:$r}} end)') || return 1
  quota_inc
  LAST_RESPONSE_FILE="$BASE/state/last-response-$$.txt"
  response="$BASE/state/api-error-$$.txt"; done_file="$BASE/state/api-done-$$"; fragment="$BASE/state/fragment-$$.txt"
  curl_cfg="$BASE/state/curl-config-$$"
  rm -f "$response" "$done_file"; : > "$LAST_RESPONSE_FILE"
  # O segredo fica num ficheiro privado, não no argumento do processo curl.
  (umask 077; printf 'header = "Authorization: Bearer %s"\n' "$(cat "$KEY_FILE")" > "$curl_cfg")
  curl -K "$curl_cfg" -sS -N --max-time 600 --fail-with-body "$BASE_URL/chat/completions" \
    -H 'Content-Type: application/json' -H 'X-Title: ntl' \
    -d "$body" 2>"$BASE/logs/curl-error.log" |
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      data:*)
        local pl="${line#data:}"; pl="${pl# }"
        if [ "$pl" = '[DONE]' ]; then : > "$done_file"; continue; fi
        if ! printf '%s' "$pl" | jq -e 'type == "object"' >/dev/null 2>&1; then printf '%s' 'Evento inválido no stream.' > "$response"; continue; fi
        if printf '%s' "$pl" | jq -e '.error != null' >/dev/null; then
          printf '%s' "$pl" | jq -r '.error.message // .error | tostring' > "$response"; continue
        fi
        if [ "$SHOW_REASONING" = '1' ]; then
          printf '%s' "$pl" | jq -j '.choices[0].delta.reasoning // empty' > "$fragment"
          if [ -s "$fragment" ]; then printf '\033[2;32m'; cat "$fragment"; printf '\033[0m'; fi
        fi
        printf '%s' "$pl" | jq -j '.choices[0].delta.content // empty' > "$fragment"
        if [ -s "$fragment" ]; then cat "$fragment"; cat "$fragment" >> "$LAST_RESPONSE_FILE"; fi
        ;;
      \{*) printf '%s' "$line" > "$response" ;;
    esac
  done
  rc=${PIPESTATUS[0]}
  rm -f "$curl_cfg" "$fragment"
  printf '\n'
  if [ -f "$response" ]; then
    echo "Erro da API: $(cat "$response")"; rm -f "$response" "$LAST_RESPONSE_FILE" "$done_file"; LAST_RESPONSE_FILE=''; return 1
  fi
  if [ "$rc" -ne 0 ] || [ ! -f "$done_file" ]; then
    echo "Resposta incompleta ou falha de rede. $(cat "$BASE/logs/curl-error.log" 2>/dev/null)"
    rm -f "$LAST_RESPONSE_FILE" "$done_file"; LAST_RESPONSE_FILE=''; return 1
  fi
  rm -f "$done_file"
  if [ ! -s "$LAST_RESPONSE_FILE" ]; then echo 'A API terminou sem resposta de texto.'; rm -f "$LAST_RESPONSE_FILE"; LAST_RESPONSE_FILE=''; return 1; fi
  return 0
}
