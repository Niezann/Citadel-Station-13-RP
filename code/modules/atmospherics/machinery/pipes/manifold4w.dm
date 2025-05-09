//
// 4-Way Manifold Pipes - 4 way "cross" junction
//
/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/atmos/manifold.dmi'
	icon_state = ""
	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"

	volume = ATMOS_DEFAULT_VOLUME_PIPE * 2

	dir = SOUTH
	initialize_directions = NORTH|SOUTH|EAST|WEST

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"

	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4

/obj/machinery/atmospherics/pipe/manifold4w/Initialize(mapload)
	. = ..()
	alpha = 255
	icon = null

/obj/machinery/atmospherics/pipe/manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)

/obj/machinery/atmospherics/pipe/manifold4w/Destroy()
	if(node1)
		node1.disconnect(src)
		node1 = null
	if(node2)
		node2.disconnect(src)
		node2 = null
	if(node3)
		node3.disconnect(src)
		node3 = null
	if(node4)
		node4.disconnect(src)
		node4 = null

	. = ..()

/obj/machinery/atmospherics/pipe/manifold4w/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node3 = null

	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node4 = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/manifold4w/change_color(var/new_color)
	..()
	//for updating connected atmos device pipes (i.e. vents, manifolds, etc)
	if(node1)
		node1.update_underlays()
	if(node2)
		node2.update_underlays()
	if(node3)
		node3.update_underlays()
	if(node4)
		node4.update_underlays()

/obj/machinery/atmospherics/pipe/manifold4w/update_icon()
	. = ..()
	if(!check_icon_cache())
		return

	alpha = 255

	cut_overlays()
	var/list/overlays_to_add = list()
	overlays_to_add += icon_manager.get_atmos_icon("manifold", , pipe_color, "4way" + icon_connect_type)
	overlays_to_add += icon_manager.get_atmos_icon("manifold", , , "clamps_4way" + icon_connect_type)
	add_overlay(overlays_to_add)
	underlays.Cut()

	/*
	var/list/directions = list(NORTH, SOUTH, EAST, WEST)


	directions -= add_underlay(node1)
	directions -= add_underlay(node2)
	directions -= add_underlay(node3)
	directions -= add_underlay(node4)

	for(var/D in directions)
		add_underlay(,D)
	*/

	var/turf/T = get_turf(src)
	var/list/directions = list(NORTH, SOUTH, EAST, WEST)
	var/node1_direction = get_dir(src, node1)
	var/node2_direction = get_dir(src, node2)
	var/node3_direction = get_dir(src, node3)
	var/node4_direction = get_dir(src, node4)

	directions -= dir

	directions -= add_underlay(T,node1,node1_direction,icon_connect_type)
	directions -= add_underlay(T,node2,node2_direction,icon_connect_type)
	directions -= add_underlay(T,node3,node3_direction,icon_connect_type)
	directions -= add_underlay(T,node4,node4_direction,icon_connect_type)

	for(var/D in directions)
		add_underlay(T,,D,icon_connect_type)


/obj/machinery/atmospherics/pipe/manifold4w/update_underlays()
	..()
	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/atmos_init()

	for(var/obj/machinery/atmospherics/target in get_step(src, NORTH))
		if (can_be_node(target, 1))
			node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src, SOUTH))
		if (can_be_node(target, 2))
			node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src, EAST))
		if (can_be_node(target, 3))
			node3 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src, WEST))
		if (can_be_node(target, 4))
			node4 = target
			break

	if(!node1 && !node2 && !node3 && !node4)
		qdel(src)
		return

	update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/visible
	icon_state = "map_4way"
	hides_underfloor = OBJ_UNDERFLOOR_NEVER

/obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map_4way-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	piping_layer = PIPING_LAYER_SCRUBBER
	layer = PIPES_SCRUBBER_LAYER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/visible/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map_4way-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	piping_layer = PIPING_LAYER_SUPPLY
	layer = PIPES_SUPPLY_LAYER
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/visible/fuel
	name="4-way fuel pipe manifold"
	desc = "A manifold composed of fuel pipes"
	icon_state = "map_4way-fuel"
	connect_types = CONNECT_TYPE_FUEL
	piping_layer = PIPING_LAYER_FUEL
	layer = PIPES_FUEL_LAYER
	icon_connect_type = "-fuel"
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/visible/aux
	name="4-way aux pipe manifold"
	desc = "A manifold composed of aux pipes"
	icon_state = "map_4way-aux"
	connect_types = CONNECT_TYPE_AUX
	piping_layer = PIPING_LAYER_AUX
	layer = PIPES_AUX_LAYER
	icon_connect_type = "-aux"
	color = PIPE_COLOR_CYAN


/obj/machinery/atmospherics/pipe/manifold4w/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/visible/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/manifold4w/visible/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/visible/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/visible/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/manifold4w/hidden
	icon_state = "map_4way"

/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map_4way-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	piping_layer = PIPING_LAYER_SCRUBBER
	layer = PIPES_SCRUBBER_LAYER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map_4way-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	piping_layer = PIPING_LAYER_SUPPLY
	layer = PIPES_SUPPLY_LAYER
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/hidden/fuel
	name="4-way fuel pipe manifold"
	desc = "A manifold composed of fuel pipes"
	icon_state = "map_4way-fuel"
	connect_types = CONNECT_TYPE_FUEL
	piping_layer = PIPING_LAYER_FUEL
	layer = PIPES_FUEL_LAYER
	icon_connect_type = "-fuel"
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/hidden/aux
	name="4-way aux pipe manifold"
	desc = "A manifold composed of aux pipes"
	icon_state = "map_4way-aux"
	connect_types = CONNECT_TYPE_AUX
	piping_layer = PIPING_LAYER_AUX
	layer = PIPES_AUX_LAYER
	icon_connect_type = "-aux"
	color = PIPE_COLOR_CYAN



/obj/machinery/atmospherics/pipe/manifold4w/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/manifold4w/hidden/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/hidden/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/hidden/purple
	color = PIPE_COLOR_PURPLE
