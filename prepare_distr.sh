mkdir $DISTR_DIR
cd $DISTR_DIR

echo "download minecraft server from official site"
curl -Os https://s3.amazonaws.com/Minecraft.Download/versions/1.12.2/minecraft_server.$MVERSION.jar 

echo "copy jre from this machine"
cp -r "$JRE" ./jre

echo "create ititial world folder"
mkdir initial_world
cd initial_world

echo "download initial map"
curl -Os https://dl01.mcworldmap.com/user/1821/world2.zip 
unzip -q world2.zip
cp -r StarWars/* .
rm -r -f StarWars
rm world2.zip
cd ../

echo "create archive (zip utility -> https://ranxing.wordpress.com/2016/12/13/add-zip-into-git-bash-on-windows/)"
cd ../
zip -r -q $DISTR_ZIP $DISTR_DIR 
rm -r -f $DISTR_DIR
