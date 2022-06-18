#!/bin/bash
TANDOORRELEASE=$(curl -s https://api.github.com/repos/TandoorRecipes/recipes/releases/latest \
| grep "tag_name" \
| awk '{print substr($2, 2, length($2)-3) }') \

RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
function update_info {
echo -e "${RD}
    _______                 _                       _____              _
   |__   __|               | |                     |  __ \            (_)
      | |  __ _  _ __    __| |  ___    ___   _ __  | |__) | ___   ___  _  _ __    ___  ___
      | | / _  ||  _ \  / _  | / _ \  / _ \ | '__| |  _  / / _ \ / __|| || '_ \  / _ \/ __|
      | || (_| || | | || (_| || (_) || (_) || |    | | \ \|  __/| (__ | || |_) ||  __/\__ \
      |_| \__,_||_| |_| \__,_| \___/  \___/ |_|    |_|  \_\\___| \___||_|| .__/  \___||___/
                                                                         | |
                   Update                                                |_|
${CL}"
}

update_info
while true; do
    read -p "This will Update Tandoor to $TANDOORRELEASE. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
sleep 2
echo -e "${GN} Stopping Tandoor... ${CL}"
sudo systemctl restart gunicorn_recipes
sleep 1

echo -e "${GN} Updating to ${TANDOORRELEASE}... ${CL}"
cd /var/www/recipes
git pull
export $(cat /var/www/recipes/.env |grep "^[^#]" | xargs)
bin/python3 manage.py migrate
bin/python3 manage.py collectstatic --no-input
bin/python3 manage.py collectstatic_js_reverse
cd vue
yarn install
yarn build
sleep 1

echo -e "${GN} Starting Tandoor... ${CL}"
sudo systemctl restart gunicorn_recipes
sleep 1
echo -e "${GN} Finished Update ${CL}"
