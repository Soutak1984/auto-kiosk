#!/bin/bash
set -e

HOSTNAME="rpi-kiosk"
USER=$(whoami)
KIOSK_DIR="/home/$USER/kiosk"

echo "Setting hostname..."
sudo hostnamectl set-hostname $HOSTNAME

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing required packages..."
sudo apt install -y nginx php-fpm php-cli \
chromium openbox lightdm unclutter openssl

echo "Enable Desktop Auto Login..."
sudo raspi-config nonint do_boot_behaviour B4

# ----------------------------------------
# CREATE KIOSK CONFIG
# ----------------------------------------

mkdir -p $KIOSK_DIR
echo "https://www.google.com" > $KIOSK_DIR/url.conf
echo "admin123" > $KIOSK_DIR/admin.pass

# ----------------------------------------
# KIOSK LAUNCH SCRIPT
# ----------------------------------------

cat > $KIOSK_DIR/kiosk.sh <<EOF
#!/bin/bash
xset -dpms
xset s off
xset s noblank
unclutter -idle 0 -root &

LAST_URL=""

while true
do
  CURRENT_URL=\$(cat $KIOSK_DIR/url.conf)

  if [ "\$CURRENT_URL" != "\$LAST_URL" ]; then
      pkill chromium || true
      sleep 2
      chromium "\$CURRENT_URL" \
      --kiosk \
      --incognito \
      --disable-infobars \
      --noerrdialogs \
      --disable-session-crashed-bubble &
      LAST_URL="\$CURRENT_URL"
  fi

  sleep 5
done
EOF

chmod +x $KIOSK_DIR/kiosk.sh

mkdir -p /home/$USER/.config/openbox
echo "$KIOSK_DIR/kiosk.sh &" > /home/$USER/.config/openbox/autostart

# ----------------------------------------
# CREATE SSL CERTIFICATE
# ----------------------------------------

echo "Creating local SSL certificate..."
sudo mkdir -p /etc/nginx/ssl

sudo openssl req -x509 -nodes -days 3650 \
-newkey rsa:2048 \
-keyout /etc/nginx/ssl/kiosk.key \
-out /etc/nginx/ssl/kiosk.crt \
-subj "/CN=$HOSTNAME"

# ----------------------------------------
# NGINX CONFIG
# ----------------------------------------

sudo rm -f /etc/nginx/sites-enabled/default

sudo bash -c "cat > /etc/nginx/sites-available/kiosk <<EOL
server {
    listen 80;
    server_name $HOSTNAME;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $HOSTNAME;

    ssl_certificate     /etc/nginx/ssl/kiosk.crt;
    ssl_certificate_key /etc/nginx/ssl/kiosk.key;

    root /var/www/kiosk;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }
}
EOL"

sudo ln -s /etc/nginx/sites-available/kiosk /etc/nginx/sites-enabled/

sudo mkdir -p /var/www/kiosk

# ----------------------------------------
# ADMIN PANEL
# ----------------------------------------

sudo bash -c "cat > /var/www/kiosk/index.php <<'PHP'
<?php
session_start();
$passfile = '/home/$USER/kiosk/admin.pass';
$urlfile  = '/home/$USER/kiosk/url.conf';

if(isset($_POST['login'])){
    $saved = trim(file_get_contents($passfile));
    if($_POST['password'] === $saved){
        $_SESSION['auth']=true;
    }
}

if(!isset($_SESSION['auth'])){
?>
<h2>Kiosk Admin Login</h2>
<form method='POST'>
<input type='password' name='password' placeholder='Password'/>
<button name='login'>Login</button>
</form>
<?php
exit;
}

if(isset($_POST['save_url'])){
    file_put_contents($urlfile, $_POST['url']);
    echo "<p style='color:green;'>URL Updated</p>";
}

if(isset($_POST['change_pass'])){
    file_put_contents($passfile, $_POST['newpass']);
    echo "<p style='color:green;'>Password Changed</p>";
}

if(isset($_POST['logout'])){
    session_destroy();
    header("Refresh:0");
}

$current = trim(file_get_contents($urlfile));
?>

<h2>Kiosk Admin Panel</h2>

<h3>Change Display URL</h3>
<form method='POST'>
<input type='text' name='url' value='<?php echo $current;?>' size='50'/>
<button name='save_url'>Save URL</button>
</form>

<h3>Change Admin Password</h3>
<form method='POST'>
<input type='password' name='newpass' placeholder='New Password'/>
<button name='change_pass'>Change Password</button>
</form>

<form method='POST'>
<button name='logout'>Logout</button>
</form>
PHP"

sudo chown -R www-data:www-data /var/www/kiosk

sudo systemctl restart nginx php-fpm

echo "Installation complete."
echo "After reboot access admin panel at:"
echo "https://$HOSTNAME"
echo ""
echo "Default password: admin123"
echo ""
echo "If https://$HOSTNAME does not open,"
echo "add router DNS entry mapping $HOSTNAME to this IP:"
hostname -I

sleep 3
sudo reboot
