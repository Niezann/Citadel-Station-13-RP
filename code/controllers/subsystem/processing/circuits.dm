//
// This is for custom circuits, mostly the initialization of global properties about them.
// Might make this also process them in the future if its better to do that than using the obj SSticker.
//
PROCESSING_SUBSYSTEM_DEF(circuit)
	name = "Circuit"
	init_order = INIT_ORDER_CIRCUIT
	subsystem_flags = SS_NO_FIRE

	var/cipherkey

	var/list/all_components = list()								// Associative list of [component_name]:[component_path] pairs
	var/list/cached_components = list()								// Associative list of [component_path]:[component] pairs
	var/list/all_assemblies = list()								// Associative list of [assembly_name]:[assembly_path] pairs
	var/list/cached_assemblies = list()								// Associative list of [assembly_path]:[assembly] pairs
	var/list/all_circuits = list()									// Associative list of [circuit_name]:[circuit_path] pairs
	var/list/circuit_fabricator_recipe_list = list()				// Associative list of [category_name]:[list_of_circuit_paths] pairs
//	var/cost_multiplier = MINERAL_MATERIAL_AMOUNT / 10 // Each circuit cost unit is 200cm3

/datum/controller/subsystem/processing/circuit/Recover()
	subsystem_flags |= SS_NO_INIT // Make extra sure we don't initialize twice.

/datum/controller/subsystem/processing/circuit/Initialize(timeofday)
	SScircuit.cipherkey = uppertext(random_string(2000+rand(0,10), GLOB.alphabet))
	circuits_init()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/circuit/proc/circuits_init()
	//Cached lists for free performance
	for(var/path in typesof(/obj/item/integrated_circuit))
		var/obj/item/integrated_circuit/IC = path
		var/name = initial(IC.name)
		all_components[name] = path // Populating the component lists
		cached_components[IC] = new path

		if(!(initial(IC.spawn_flags) & (IC_SPAWN_DEFAULT | IC_SPAWN_RESEARCH)))
			continue

		var/category = initial(IC.category_text)
		if(!circuit_fabricator_recipe_list[category])
			circuit_fabricator_recipe_list[category] = list()
		var/list/category_list = circuit_fabricator_recipe_list[category]
		category_list += IC // Populating the fabricator categories

	for(var/path in typesof(/obj/item/electronic_assembly))
		var/obj/item/electronic_assembly/A = path
		var/name = initial(A.name)
		all_assemblies[name] = path
		cached_assemblies[A] = new path

	for(var/path in NON_STANDARD_CIRCUIT_LIST)
		var/obj/item/A = path
		var/name = initial(A.name)
		all_assemblies[name] = path
		cached_assemblies[A] = new path

	circuit_fabricator_recipe_list["Assemblies"] = list(
		/obj/item/electronic_assembly/tiny/default,
		/obj/item/electronic_assembly/tiny/cylinder,
		/obj/item/electronic_assembly/tiny/scanner,
		/obj/item/electronic_assembly/tiny/hook,
		/obj/item/electronic_assembly/tiny/box,
		/obj/item/electronic_assembly/tiny/dildo,
		/obj/item/electronic_assembly/default,
		/obj/item/electronic_assembly/calc,
		/obj/item/electronic_assembly/clam,
		/obj/item/electronic_assembly/simple,
		/obj/item/electronic_assembly/hook,
		/obj/item/electronic_assembly/pda,
		/obj/item/electronic_assembly/dildo,
		/obj/item/electronic_assembly/medium/default,
		/obj/item/electronic_assembly/medium/box,
		/obj/item/electronic_assembly/medium/clam,
		/obj/item/electronic_assembly/medium/medical,
		/obj/item/electronic_assembly/medium/gun,
		/obj/item/electronic_assembly/medium/radio,
		/obj/item/electronic_assembly/medium/dildo,
		/obj/item/electronic_assembly/large/default,
		/obj/item/electronic_assembly/large/scope,
		/obj/item/electronic_assembly/large/terminal,
		/obj/item/electronic_assembly/large/arm,
		/obj/item/electronic_assembly/large/tall,
		/obj/item/electronic_assembly/large/industrial,
		/obj/item/electronic_assembly/large/vendor,
		/obj/item/electronic_assembly/drone/default,
		/obj/item/electronic_assembly/drone/arms,
		/obj/item/electronic_assembly/drone/secbot,
		/obj/item/electronic_assembly/drone/medibot,
		/obj/item/electronic_assembly/drone/genbot,
		/obj/item/electronic_assembly/drone/android,
		/obj/item/electronic_assembly/wallmount/tiny,
		/obj/item/electronic_assembly/wallmount/light,
		/obj/item/electronic_assembly/wallmount,
		/obj/item/electronic_assembly/wallmount/heavy,
		/obj/item/implant/integrated_circuit,
		/obj/item/clothing/under/circuitry,
		/obj/item/clothing/gloves/circuitry,
		/obj/item/clothing/gloves/ewatch,
		/obj/item/clothing/glasses/circuitry,
		/obj/item/clothing/shoes/circuitry,
		/obj/item/clothing/head/circuitry,
		/obj/item/clothing/ears/circuitry,
		/obj/item/clothing/suit/circuitry
		)

	circuit_fabricator_recipe_list["Tools"] = list(
		/obj/item/integrated_electronics/wirer,
		/obj/item/integrated_electronics/debugger,
		/obj/item/integrated_electronics/analyzer,
		/obj/item/integrated_electronics/detailer,
		/obj/item/card/data
		)
