#TYPEWRITTEN_PREFIX!/usr/bin/env zsh

#      ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____
#     ||t |||y |||p |||e |||w |||r |||i |||t |||t |||e |||n ||
#     ||__|||__|||__|||__|||__|||__|||__|||__|||__|||__|||__||
#     |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
#             A minimal, informative zsh prompt theme
#

export TYPEWRITTEN_ROOT=${${(%):-%x}:A:h}

source "$TYPEWRITTEN_ROOT/async.zsh"
async_init

source "$TYPEWRITTEN_ROOT/lib/colors.zsh"
source "$TYPEWRITTEN_ROOT/lib/git.zsh"

BREAK_LINE="
"

local tw_prompt_symbol="❯"
if [ ! -z "$TYPEWRITTEN_SYMBOL" ]; then
  tw_prompt_symbol="$TYPEWRITTEN_SYMBOL"
fi;

local tw_base_symbol_color="%F{$tw_colors[symbol]}"
if [[ $(id -u) -eq 0 ]]; then
  tw_base_symbol_color="%F{$tw_colors[symbol_root]}"
fi

local tw_prompt_color="%(?,$tw_base_symbol_color,%F{$tw_colors[symbol_error]})"
local tw_return_code="%(?,,%F{$tw_colors[error_code]}%? )"
if [ "$TYPEWRITTEN_DISABLE_RETURN_CODE" = true ]; then
  tw_prompt_color="$tw_base_symbol_color"
  tw_return_code=""
fi;

tw_user_host="%F{$tw_colors[host]}%n%F{$tw_colors[host_user_connector]}@%F{$tw_colors[user]}%m"
tw_prompt="$tw_prompt_color$tw_return_code$tw_prompt_symbol %F{$tw_colors[prompt]}"

tw_current_directory_color="$tw_colors[current_directory]"
tw_git_branch_color="$tw_colors[git_branch]"

local tw_arrow_symbol="->"
if [ ! -z "$TYPEWRITTEN_ARROW_SYMBOL" ]; then
  tw_arrow_symbol="$TYPEWRITTEN_ARROW_SYMBOL"
fi;
tw_arrow="%F{$tw_colors[arrow]}$tw_arrow_symbol"

tw_get_virtual_env() {
  if [[ -z $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    local tw_virtual_env=""
    if [[ ! -z $VIRTUAL_ENV ]]; then
      tw_virtual_env="$VIRTUAL_ENV"
    elif [[ ! -z $CONDA_PREFIX ]]; then
      tw_virtual_env="$CONDA_PREFIX"
    fi;

    if [[ $tw_virtual_env != "" ]]; then
      echo "%F{$tw_colors[virtual_env]}($(basename $tw_virtual_env)) "
    fi;
  fi;
}

tw_get_displayed_wd() {
  local tw_git_branch=$tw_prompt_data[tw_git_branch]
  local tw_git_home=$tw_prompt_data[tw_git_home]

  local tw_home_relative_wd="%~"
  local tw_git_relative_wd="$tw_git_home%c"

  local tw_displayed_wd="$tw_git_relative_wd"

  # The pure layout defaults to home relative working directory, but allows customization
  if [[ "$TYPEWRITTEN_PROMPT_LAYOUT" = pure* && "$TYPEWRITTEN_RELATIVE_PATH" = "" ]]; then
    tw_displayed_wd=$tw_home_relative_wd
  fi;

  if [[ "$TYPEWRITTEN_RELATIVE_PATH" = "home" ]]; then
    tw_displayed_wd=$tw_home_relative_wd
  fi;

  if [[ "$TYPEWRITTEN_RELATIVE_PATH" = "adaptive" ]]; then
    if [[ "$tw_git_branch" = "" ]]; then
      tw_displayed_wd=$tw_home_relative_wd
    fi;
  fi;

  echo "%F{$tw_current_directory_color}$tw_displayed_wd"
}

tw_get_left_prompt_prefix() {
  local tw_left_prompt_prefix=""

  if [[ ! -z $TYPEWRITTEN_LEFT_PROMPT_PREFIX || ! -z $TYPEWRITTEN_LEFT_PROMPT_PREFIX_FUNCTION ]]; then
    tw_left_prompt_prefix="%F{$tw_colors[left_prompt_prefix]}"
  fi;

  if [[ ! -z $TYPEWRITTEN_LEFT_PROMPT_PREFIX ]]; then
    tw_left_prompt_prefix="$tw_left_prompt_prefix$TYPEWRITTEN_LEFT_PROMPT_PREFIX "
  fi;

  if [[ ! -z $TYPEWRITTEN_LEFT_PROMPT_PREFIX_FUNCTION ]]; then
    local value=$($TYPEWRITTEN_LEFT_PROMPT_PREFIX_FUNCTION) 2>/dev/null

    if [[ ! -z $value ]]; then
      tw_left_prompt_prefix="$tw_left_prompt_prefix$value "
    fi;
  fi;

  echo $tw_left_prompt_prefix
}

tw_get_right_prompt_prefix() {
  local tw_right_prompt_prefix=""

  if [[ ! -z $TYPEWRITTEN_RIGHT_PROMPT_PREFIX || ! -z $TYPEWRITTEN_RIGHT_PROMPT_PREFIX_FUNCTION ]]; then
    tw_right_prompt_prefix="%F{$tw_colors[right_prompt_prefix]}"
  fi;

  if [[ ! -z $TYPEWRITTEN_RIGHT_PROMPT_PREFIX ]]; then
    tw_right_prompt_prefix="$tw_right_prompt_prefix$TYPEWRITTEN_RIGHT_PROMPT_PREFIX "
  fi;

  if [[ ! -z $TYPEWRITTEN_RIGHT_PROMPT_PREFIX_FUNCTION ]]; then
    local value=$($TYPEWRITTEN_RIGHT_PROMPT_PREFIX_FUNCTION) 2>/dev/null

    if [[ ! -z $value ]]; then
      tw_right_prompt_prefix="$tw_right_prompt_prefix$value "
    fi;
  fi;

  echo $tw_right_prompt_prefix
}

tw_redraw() {
  local tw_displayed_wd="$(tw_get_displayed_wd)"

  local tw_full_prompt="$(tw_get_virtual_env)$(tw_get_left_prompt_prefix)$tw_prompt"

  local tw_layout="$TYPEWRITTEN_PROMPT_LAYOUT"
  local tw_git_info="$tw_prompt_data[tw_git_branch]$tw_prompt_data[tw_git_status]"

  if [ "$tw_layout" = "half_pure" ]; then
    PROMPT="%F{$tw_git_branch_color}$tw_git_info$BREAK_LINE$tw_full_prompt"
    RPROMPT="$(tw_get_right_prompt_prefix)$tw_displayed_wd"
  else
    local tw_git_arrow_info=""
    if [ "$tw_git_info" != "" ]; then
      tw_git_arrow_info=" $tw_arrow %F{$tw_git_branch_color}$tw_git_info"
    fi;

    local tw_right_prompt_prefix="$(tw_get_right_prompt_prefix)"

    PROMPT="$tw_full_prompt"
    RPROMPT="$tw_right_prompt_prefix$tw_displayed_wd$tw_git_arrow_info"

    if [ "$tw_layout" = "pure" ]; then
      PROMPT="$tw_displayed_wd$tw_git_arrow_info$BREAK_LINE$tw_full_prompt"
      RPROMPT=""
    fi;

    if [ "$tw_layout" = "pure_verbose" ]; then
      PROMPT="$tw_user_host $tw_displayed_wd$tw_git_arrow_info$BREAK_LINE$tw_full_prompt"
      RPROMPT=""
    fi;

    if [ "$tw_layout" = "singleline_verbose" ]; then
      PROMPT="$tw_user_host $tw_full_prompt"
      RPROMPT="$tw_right_prompt_prefix$tw_displayed_wd$tw_git_arrow_info"
    fi;

    if [ "$tw_layout" = "multiline" ]; then
      PROMPT="$tw_user_host$BREAK_LINE$tw_full_prompt"
      RPROMPT="$tw_right_prompt_prefix$tw_displayed_wd$tw_git_arrow_info"
    fi;
  fi;


  if (( $+functions[iterm2_prompt_mark] )); then
    PROMPT="%{$(iterm2_prompt_mark)%}$PROMPT%{$(iterm2_prompt_end)%}"
  fi

  zle -R && zle reset-prompt
}

tw_async_init_worker() {
  async_start_worker tw_worker -n
  async_register_callback tw_worker tw_prompt_callback
}

tw_prompt_callback() {
  local tw_name=$1 tw_code=$2 tw_output=$3
  if (( tw_code == 2 )) || (( tw_code == 3 )) || (( tw_code == 130 )); then
    # reinit async workers
    async_stop_worker tw_worker
    tw_async_init_worker
    tw_async_init_tasks
  elif (( tw_code )); then
    tw_async_init_tasks
  fi;
  tw_prompt_data[$tw_name]=$tw_output
  tw_redraw
}

tw_async_init_tasks() {
  typeset -Ag tw_prompt_data

  local tw_current_pwd="$PWD"
  async_worker_eval tw_worker builtin cd -q $tw_current_pwd

  local tw_git_hide_status="$(git config --get oh-my-zsh.hide-status 2>/dev/null)"
  if [[ "$tw_git_hide_status" != "1" ]]; then
    local tw_git_toplevel="$(git rev-parse --show-toplevel 2>/dev/null)"

    if [[ "$tw_current_pwd" != $tw_prompt_data[tw_current_pwd] ]]; then
      async_flush_jobs tw_worker
      tw_prompt_data[tw_git_home]=
    fi;

    if [[ "$tw_git_toplevel" != $tw_prompt_data[tw_git_toplevel] ]]; then
      async_flush_jobs tw_worker
      tw_prompt_data[tw_git_branch]=
      tw_prompt_data[tw_git_status]=
    fi;

    tw_prompt_data[tw_git_toplevel]="$tw_git_toplevel"
    tw_prompt_data[tw_current_pwd]="$tw_current_pwd"
    if [[ "$TYPEWRITTEN_RELATIVE_PATH" = "git" || "$TYPEWRITTEN_RELATIVE_PATH" = "adaptive" ]]; then
      async_job tw_worker tw_git_home $tw_current_pwd $tw_git_toplevel
    fi;
    async_job tw_worker tw_git_branch
    async_job tw_worker tw_git_status
  else
    tw_prompt_data[tw_git_branch]=
    tw_prompt_data[tw_git_status]=
  fi;

  tw_redraw
}

# prompt cursor fix when exiting vim
tw_fix_cursor() {
  local tw_cursor="\e[3 q"
  if [ "$TYPEWRITTEN_CURSOR" = "block" ]; then
    tw_cursor="\e[1 q"
  elif [ "$TYPEWRITTEN_CURSOR" = "beam" ]; then
    tw_cursor="\e[5 q"
  fi;
  echo -ne "$tw_cursor"
}

tw_setup() {
  tw_async_init_worker
  tw_async_init_tasks

  zmodload zsh/zle
  autoload -Uz add-zsh-hook
  if [ "$TYPEWRITTEN_CURSOR" != "terminal" ]; then
    add-zsh-hook precmd tw_fix_cursor
  fi;
  add-zsh-hook precmd tw_async_init_tasks

  PROMPT="$tw_prompt"
}
tw_setup

zle_highlight=( default:fg=$tw_colors[prompt] )
