[mod] 3d wielded items [wield3d]
================================

Mod Version: 0.5.0

Minetest Version: 5.0.0 or later

Decription: Visible 3d wielded items for Minetest

Makes hand wielded items visible to other players.

By default the wielded object is updated at one second intervals,
you can override this by adding `wield3d_update_time = 1` (seconds)
to your minetest.conf

Servers can also control how often to verify the wield item of each
individual player by setting `wield3d_verify_time = 10` (seconds)

The default wielditem scale can now be specified by including `wield3d_scale = 0.25`
