# openvpn-dkr

![WTFPL](./wtfpl-badge-4.png)

# Контейнер c OpenVPN сервером

- Помогает быстро сконфигурировать и запустить VPN сервер протокола OpenVPN
- поддержка PKI для пользователей, с добавлением / удалением / просмотром



## Получение справки

       docker run --rm -v ovpn-u:/etc/openvpn stim/ovpn --help
   Выхлоп:

    >     docker run stim/openvpn-dkr [config|client_list|client_new|client_del|client_get] [options]
    > 
    >         w/o arguments it run OpenVPN server according to prevoisly
    >         generated config. If no config was generated or some options are
    >         specified on the line starting with '-' sign, then it first run
    >         configure step as <config> command was passed then run server.
    > 
    >     By default routed networking wil be used with attempt to route
    >       all localy configured networks
    > 
    >     COMMANDS:
    > 
    >     config [options]
    >         run configure step - generate PKI and client/server configs:
    > 
    >       --uri <proto://public_address:port>
    >         specifieces target server endpoint proto can be udp or tcp,
    >         public_address - should be ip or DNS name of server externaly
    >         available for clients, port - denotes port openvpn server should
    >         listen on
    > 
    >       --reinit
    >         regenerate PKI, with new CA and server crt/key
    > 
    >       --bridged [ip/bits start_ip end_ip]
    >         use tap device and build bridged networking for clients.
    >         ip/bits - is address and netmask in CIDR notation of server in
    >         bridged network, client gets addresses from start_ip to end_ip,
    >         by default it gets 10.57.0.1/16 10.57.0.4 10.57.254.253
    > 
    >       --routed [ip/bits]
    >         use tun device and build routed networking for clients.
    >         ip/bits - ip address for server and netmask for network in
    >         CIDR notation
    > 
    >       --route-all
    >         route all addresses to VPN
    > 
    >       --route-add <ip/bits>
    >         route specefied network adresses to VPN, this option may be
    >         repeated several times, to add several networks. It is redundant
    >         if '--route-all' option is used
    > 
    >       --set-dns <ip>
    >         set specefied IP as DNS server
    > 
    >     client_list [all|active|revoked]
    >         list registered clients
    > 
    >         all include active and revoked clients
    >         active (default) include active clients only
    >         revoked (default) include revoked clients only
    > 
    >     client_new <name>
    >         create new client
    > 
    >     client_del <name>
    >         delete client
    > 
    >     client_get [combo|ca|ta|cert|key|cf]
    >         print out client config files:
    >             combo (default) concatenated config with all parts needed
    >             ca server CA
    >             ta TLS authentication key
    >             cert client X509 certificate
    >             key client private key
    >             cf client openVPN config

## Создание и запуск

1. создание конфигурации

       docker run --rm -v ovpn-u:/etc/openvpn stim/ovpn config --uri udp://92.38.240.241:443 --routed --route-all --set-dns 1.1.1.1
   тут создаём простую конфигурацию из того что нужно отметить:

   - `-v ovpn-u:/etc/openvpn` автоматом создаём докер volume `ovpn-u` там будут записаны конфигурация сервера и PKI пользователей,
     чтобы впоследствии запускать OpenVPN сервер с этой конфигурацией достаточно смонтировать этот volume в `/etc/openvpn`
     (так же как и в этой команде)
   - `--uri udp://92.38.240.241:443` это указывает публичный адрес и порт по которому пользователи должны будут устанавливать
     соединение, это записывается в генерируемые конфигурационные файлы пользователей
   
   остальное стоит посмотреть в хелпе выше
  

2. запуск сконфигурированного контейнера

       docker run -d --restart=always --privileged -v ovpn-u:/etc/openvpn -p 443:443/udp --name ovpn-u stim/ovpn
   - `--privileged` нужендля нормальной работы (создание tun девайсов)
   - `--privileged -v ovpn-u:/etc/openvpn` монтируем в нужное место том с конфигами
   - `-p 443:443/udp` замапим порт хоста 443 на порт контейнера 443
   - `--restart=always` всегда наплаву

---

## Управление пользователями (PKI)

Эти команды можно запускать при уже работающем сервисе, им обязательно надо передавать опцию 
`-v <volume_name>:/etc/openvpn`, чтобы они работали с тем же volume который был использован при конфигурировании
и запуске сервиса

1. Создать нового пользователя

       docker run --rm -v ovpn-u:/etc/openvpn stim/ovpn client_new il

2. Посмотреть список пользователей

       docker run --rm -v ovpn-u:/etc/openvpn stim/ovpn client_list

3. Получить конфиг пользователя (и записать в файл)
   
       docker run --rm -v ovpn-u:/etc/openvpn stim/ovpn client_get <clien_name> > client_config.ovpn


