#!/bin/bash
echo "Lets Starts Config auto backup to S3"

DIR="$(cd "$(dirname "$0")" && pwd)"


if [ ! -d "/var/www/backup/backup.sh" ]; then
    mkdir /var/www/backup/
fi

if [ -f "/var/www/backup/backup.sh" ]; then
    rm /var/www/backup/backup.sh
fi

touch /var/www/backup/backup.sh

echo "#!/bin/bash" >> /var/www/backup/backup.sh

echo "instaling dependencies..."
sudo apt-get update
sudo apt-get install s3cmd
sudo apt-get install awscli -y
sudo npm install -g slack-cli
echo "dependencies OK, lets configre enviroment"

sudo s3cmd --configure

echo "S3_BUCKET=convenia-backups \\" >> /var/www/backup/backup.sh
echo "Mysql Host? "
read input_variable
echo "MYSQL_HOST=$input_variable \\" >> /var/www/backup/backup.sh
echo "MySQL User? "
read input_variable
echo "MYSQL_USER=$input_variable \\" >> /var/www/backup/backup.sh
echo "MYSQL_PORT=3306 \\" >> /var/www/backup/backup.sh
echo "MySQL Pass? "
read input_variable
echo "MYSQL_PASS=$input_variable \\" >> /var/www/backup/backup.sh
echo "MySQL DB? "
read input_variable
echo "MYSQL_DB=$input_variable \\" >> /var/www/backup/backup.sh
echo "/var/www/backup/routine.sh" >> /var/www/backup/backup.sh

chmod +x /var/www/backup/backup.sh
cp $DIR/routine.sh /var/www/backup/routine.sh
chmod +x /var/www/backup/routine.sh

echo "whats time cron needs run [0-24] ? "
read input_variable
crontab -e > backup.cron
echo "0 $input_variable * * * /var/www/backup/backup.sh >/dev/null 2>&1" >> backup.cron

if [ ! -f "$HOME/.bashrc" ]; then
    touch $HOME/.bashrc
fi
echo "Slack token ? "
read input_variable
echo "export SLACK_TOKEN=$input_variable" >>  $HOME/.bashrc
source ~/.bashrc
crontab mycron
echo "Perfect, instaled! plese feedback victor.ventura@convenia.com.br"
