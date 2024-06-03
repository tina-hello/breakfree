#!/usr/bin/env sh
export GOPROXY="https://proxy.golang.org,direct" GOAMD64='v3'

git clone https://github.com/SagerNet/serenity
cd serenity && make install && cd ..
serenity -c serenity.json run &
sleep 15

curl -fsS -o "servers.json" http://localhost:8080/servers
curl -fsS -o "servers-lite.json" http://localhost:8080/servers-lite

#quick-fix
sed -i s/\;mux\=true//g servers.json servers-lite.json
sed -i s/mux\=true\;//g servers.json servers-lite.json

python main.py servers.json templates/template-ir.json ir.json
python main.py servers.json templates/template-ir-sfw.json ir-sfw.json
python main.py servers.json templates/template-ir-notun.json ir-notun.json
python main.py servers-lite.json templates/template-ir.json ir-lite.json
python main.py servers-lite.json templates/template-ir-sfw.json ir-sfw-lite.json
python main.py servers-lite.json templates/template-ir-notun.json ir-lite-notun.json
echo "IR files exported!"

python main.py servers.json templates/template-cn.json cn.json
python main.py servers.json templates/template-cn-sfw.json cn-sfw.json
python main.py servers.json templates/template-cn-notun.json cn-notun.json
python main.py servers-lite.json templates/template-cn.json cn-lite.json
python main.py servers-lite.json templates/template-cn-sfw.json cn-sfw-lite.json
python main.py servers-lite.json templates/template-cn-notun.json cn-lite-notun.json
echo "CN files exported!"

git clone https://github.com/SagerNet/sing-box
cd sing-box && git checkout main-next && make install && cd ..

for i in ir*.json cn*.json; do sing-box -c "$i" check && echo "'$i' is OK!"; done

mv ir*.json cn*.json release/Sing-Box/
echo "SUCCESS!"
