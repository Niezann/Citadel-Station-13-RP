/datum/prototype/design/science/beaker
	abstract_type = /datum/prototype/design/science/beaker

/datum/prototype/design/science/beaker/generate_name(template)
	return "Beaker prototype ([template])"

/datum/prototype/design/science/beaker/noreact
	design_name = "cryostasis"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	req_tech = list(TECH_MATERIAL = 2)
	materials_base = list(MAT_STEEL = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/noreact

/datum/prototype/design/science/beaker/bluespace
	design_name = TECH_BLUESPACE
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	req_tech = list(TECH_BLUESPACE = 2, TECH_MATERIAL = 6)
	materials_base = list(MAT_STEEL = 3000, MAT_PHORON = 3000, MAT_DIAMOND = 500)
	build_path = /obj/item/reagent_containers/glass/beaker/bluespace
