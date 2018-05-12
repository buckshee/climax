What is MaxCoin?
==============

Maxcoin is an alternative cryptocurrency introduced in 2014.

Technical Information

+ ~100,000,000 coins
+ 8 coins rewarded per block, halving every 4 years
+ 60 second block times
+ difficulty retargeting using a time-warp resistant implementation of KGW

Notable differences from Bitcoin
-----------------------------

+ replacement of ECDSA with Schnorr signing
+ use of secp256r1 curve over secp256k1
+ requirement for public key when verifying transactions

Modifications to the RPC API
+ verifymessage <publickey> <signature> <message>
+ makekeypair [hex-encoded prefix]
+ dumppubkey <maxcoinaddress>

Additional technical details can be found in the [Wiki](https://github.com/Max-Coin/maxcoin/wiki/_pages).

Forked from Bitcoin reference wallet 0.8.5 and Blakecoin

Installation
-----

```
apt update && apt -y dist-upgrade
apt install git-core build-essential libssl-dev libboost-{system,program-options,thread,filesystem}-dev libdb-dev libdb++-dev  libleveldb-dev
cd /usr/src
git clone https://github.com/buckshee/maxcoin.git
cd /usr/src/maxcoin/src/
make
cp maxcoind /usr/local/bin
mkdir /var/lib/maxcoin
useradd -r -d /var/lib/maxcoin maxcoind
chown -R maxcoind:maxcoind /var/lib/maxcoin
mkdir /etc/maxcoin
./maxcoind 2>&1 | egrep 'rpcuser=|rpcpassword=' | tee /etc/maxcoin/maxcoind.conf
cp ../contrib/maxcoind.service /etc/systemd/system/
systemctl enable maxcoind
```

Download a bootsrap file:

`wget -O /var/lib/maxcoin/bootstrap.dat http://54.36.19.200/bootstrap.dat`


To compile on systems with 1Gb RAM, try adding temporary swap:

```
fallocate -l 1G /.swapfile
mkswap /.swapfile
chmod 600 /.swapfile
swapon /.swapfile
```

Compilation fails on OpenSSL 1.1, which is a problem for many non Ubuntu systems.

```
export LDFLAGS+=" -L/usr/lib/openssl-1.0 -lssl"
export CPPFLAGS+=" -I/usr/include/openssl-1.0"
```

License
------

MaxCoin is released under the terms of the MIT license. See `COPYING` for more
information or see http://opensource.org/licenses/MIT.
