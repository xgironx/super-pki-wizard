brew install git
curl -sSL https://raw.githubusercontent.com/ga-dc/installfest/master/support/gitignore_global -o ~/.gitignore_global
git config --global user.name xgironx
git config --global user.email xgironx@gmail.com
git config --global push.default simple
git config --global color.ui always
    git config --global color.branch.current   "green reverse"
    git config --global color.branch.local     green
    git config --global color.branch.remote    yellow
    git config --global color.status.added     green
    git config --global color.status.changed   yellow
    git config --global color.status.untracked red
git config --global core.ignorecase false
git config --global core.editor atom
mv ~/.gitignore_global ~/.gitignore_global.bak

git config --global core.excludesfile ~/.gitignore_global
export GITHUB_USERNAME='xgironx'>> ~/.bash_profile
export GITHUB_USERNAME='XGIRONX'>> ~/.bash_profile
export GITHUB_USERNAME='xgironx'>> ~/.bash_profile
echo export GITHUB_USERNAME='xgironx'>> ~/.bash_profile

brew install bash-completion
echo "[  [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh""    >> ~/xgirobash

xcode-select --install                  #INSTALL CLI TOOLS
brew install emacs
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew cask install emacs

git remote add super-pki-wizard   https://github.com/xgironx/super-pki-wizard.git
git push --set-upstream origin master
                                        Username for 'https://github.com': xgironx
                                        Password for 'https://xgironx@github.com': 
git remote add origin git@github.com:xgironx/super-pki-wizard.git > /dev/null 2>&1
git pull git@github.com:xgironx/super-pki-wizard.git


