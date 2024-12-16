#!/bin/bash

# Инициализация переменных
options=()
parameters=()
seen_a=false
seen_v=false
help_flag=false
version_flag=false
usage_flag=false

# Функция вывода справки
show_help() {
  echo "Usage: $0 [-a] [-v] [--] pars..."
  echo "  -a          Опция A"
  echo "  -v          Опция V"
  echo "  --help      Показать справку"
  echo "  --version   Показать информацию о версии"
}
# Функция вывода справки
show_usage() {
  echo "Usage: $0 [-a] [-v] [--] pars..."
}
# Функция вывода версии
show_version() {
  echo "Scriptname version 1.0"
  echo "Автор:  Джуфри"
}

# Перебор аргументов
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a)
      if ! $seen_a; then
        options+=("-a")
        seen_a=true
      fi
      shift
      ;;
    -v)
      if ! $seen_v; then
        options+=("-v")
        seen_v=true
      fi
      shift
      ;;
    --help)
      help_flag=true
      shift
      ;;
    --usage)
      usage_flag=true
      shift
    ;;
    --version)
      version_flag=true
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Ошибка: Неизвестная опция $1" >&2
      exit 1
      ;;
    *)
      parameters+=("$1")
      shift
      ;;
  esac
done

# Вывод справки или версии, если флаги активированы
if $help_flag; then
  show_help
  exit 0
fi

if $version_flag; then
  show_version
  exit 0
fi

if $usage_flag; then
  show_usage
  exit 0
fi
# Вывод информации о заданных опциях
if $seen_a; then
  echo "-a задана"
else
  echo "-a не задана"
fi

if $seen_v; then
  echo "-v задана"
else
  echo "-v не задана"
fi

# Вывод параметров
for param in "${parameters[@]}"; do
  echo "$param"
done

# Вывод оставшихся аргументов после '--'
for remaining in "$@"; do
  echo "$remaining"
done
