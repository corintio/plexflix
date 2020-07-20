queue_length() {
    find ~/plexflix/data/local -type f | grep -v downloads | wc -l
}
queue_size() {
    du -sh ~/plexflix/data/local --exclude ~/plexflix/data/local/downloads | cut -f1
}
upload_queue() {
    echo "Upload Queue: $(queue_length) files, $(queue_size)"
}
alias queue_info='watch -t -n 10 -d -x $SHELL -c "source ~/.custom; upload_queue"'

#alias ctop='docker run --rm -ti --name=ctop -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest'
alias ddc='f() { (cd ~/plexflix && docker-compose $@) }; f'
alias borgmatic='ddc run --rm  borgmatic borgmatic'
alias borg='ddc run --rm borgmatic borg'
alias logerr='ddc logs -f -t --tail=1 | egrep -i "(warn|error|fail)"'
alias rclone='ddc exec rclone rclone'
alias up='ddc up -d --build'
alias wls='f() { watch -d -c ls -l --color \"$@\"; }; f'
