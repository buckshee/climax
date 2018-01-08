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

Installation - Ubuntu 14.04
-----

```
apt update && apt -y dist-upgrade
apt install git-core build-essential libssl-dev libboost-{system,program_options,thread,filesystem}-dev libdb-dev libdb++-dev
cd /usr/src
git clone https://github.com/buckshee/maxcoin.git
cd /usr/src/maxcoin/src/
make
cp maxcoind /usr/local/bin
useradd -m -r -d /srv/maxcoin maxcoind
mkdir /etc/maxcoin
./maxcoind 2>&1 | egrep 'rpcuser=|rpcpassword=' | tee /etc/maxcoin/maxcoind.conf
cp ../contrib/maxcoind.conf_upstart /etc/init/maxcoind.conf
```

Compilation fails on OpenSSL 1.1, notes on code changes feathercoin and peercoin, may not be used any more in recent core versions

export LDFLAGS+=" -L/usr/lib/openssl-1.0 -lssl"
export CXXFLAGS+=" -I/usr/include/openssl-1.0"


License
------

MaxCoin is released under the terms of the MIT license. See `COPYING` for more
information or see http://opensource.org/licenses/MIT.
