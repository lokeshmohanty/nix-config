set -g fish_greeting
fish_vi_key_bindings

abbr -a e 'emacsclient -c -a nvim'
abbr -a d docker
abbr -a g git
abbr -a s 'sudo -E'
abbr -a p python
abbr -a t tmux
abbr -a ta 'tmux attach -t'
abbr -a tn 'tmux new-session -t'
abbr -a tl 'tmux list-sessions'
abbr -a tk 'tmux kill-session -t'
abbr -a k kubectl
abbr -a kg 'kubectl get'
abbr -a kl 'kubectl logs'
abbr -a ke 'kubectl exec -it'
abbr -a kgp 'kubectl get pods'

function gitignore
  curl -sL "https://www.gitignore.io/api/$argv"
end

function tab
  jc -l $argv | jtbl
end
