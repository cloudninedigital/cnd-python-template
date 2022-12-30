unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

case "${machine}" in
  Linux|Mac)
    venv_scripts_dir="bin"
    python_exe="python"
    pip_file="pip.conf"
    ;;
  Cygwin|MinGw)
    venv_scripts_dir="Scripts"
    python_exe="py"
    pip_file="pip.ini"
    ;;
esac

source ".venv/${bin}/activate"
${python_exe} -m pip install keyring keyrings.google-artifactregistry-auth

cp .github/pip/pip.conf ".venv/${pip_file}"
if [ ! -f "$HOME" ]; then
  cp "${github_dir}/pip/.pypirc" "${HOME}/.pypirc"
fi