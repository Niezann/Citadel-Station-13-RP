/obj/item/grenade/smokebomb
	desc = "It is set to detonate in 2 seconds. These high-tech grenades can have their color adapted on the fly with a multitool!"
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	slot_flags = SLOT_BELT
	worth_intrinsic = 50
	var/datum/effect_system/smoke_spread/bad/smoke
	var/smoke_color
	var/smoke_strength = 8

/obj/item/grenade/smokebomb/Initialize(mapload)
	. = ..()
	src.smoke = new /datum/effect_system/smoke_spread/bad()
	src.smoke.attach(src)

/obj/item/grenade/smokebomb/Destroy()
	qdel(smoke)
	smoke = null
	return ..()

/obj/item/grenade/smokebomb/detonate()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	src.smoke.set_up(10, 0, usr.loc)
	spawn(0)
		for(var/i = 1 to smoke_strength)
			src.smoke.start(smoke_color)
			sleep(10)
		qdel(src)

	return

/obj/item/grenade/smokebomb/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/multitool))
		var/new_smoke_color = input(user, "Choose a color for the smoke:", "Smoke Color", smoke_color) as color|null
		if(new_smoke_color)
			smoke_color = new_smoke_color
