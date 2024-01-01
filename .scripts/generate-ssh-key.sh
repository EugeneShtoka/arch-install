ssh-keygen -t ed25519 -C $1
sleep 3
mv ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_$2
mv ~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519_$2.pub
ssh-add ~/.ssh/id_ed25519_$2
echo "Login to github, open $3 and paste this key"
cat ~/.ssh/id_ed25519_$2.pub
