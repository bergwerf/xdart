X for Dart
==========
In order to run `bin/demo.dart`, you need to enable TCP listening for the X
server. Under Ubuntu it is possible to add the following to
`/etc/lightdm/lightdm.conf`. Note that Wireshark has support for the X11
protocol and can be very helpful to understand the details.

```
[SeatDefaults]
xserver-allow-tcp=true

[security]
DisallowTCP=false
```
