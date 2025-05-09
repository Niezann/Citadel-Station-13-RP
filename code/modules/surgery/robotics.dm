//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/
	can_infect = 0
	surface_odd_buff = 30 // can do it basically anywhere but a floor

/datum/surgery_step/robotics/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..()) return FALSE
	if (isslime(target))
		return 0
	if (target_zone == O_EYES)	//there are specific steps for eye surgery
		return 0
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected == null)
		return 0
	if (affected.status & ORGAN_DESTROYED)
		return 0
	if (!(affected.robotic == ORGAN_ROBOT || affected.robotic == ORGAN_LIFELIKE))
		return 0
	return 1

///////////////////////////////////////////////////////////////
// Unscrew Hatch Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/unscrew_hatch
	step_name = "Unscrew hatch"

	allowed_tools = list(
		/obj/item/coin = 50,
		/obj/item/material/knife = 50
	)

	allowed_procs = list(IS_SCREWDRIVER = 100)

	req_open = 0

	min_duration = 20
	max_duration = 30

/datum/surgery_step/robotics/unscrew_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.open == 0 && target_zone != O_MOUTH

/datum/surgery_step/robotics/unscrew_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 1

/datum/surgery_step/robotics/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>", \
	"<span class='warning'>Your [tool] slips, failing to unscrew [target]'s [affected.name].</span>")

///////////////////////////////////////////////////////////////
// Open Hatch Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/open_hatch
	step_name = "Open hatch"

	allowed_tools = list(
		/obj/item/surgical/retractor = 100,
		/obj/item/surgical/retractor_primitive = 75,
		/obj/item/material/kitchen/utensil = 50
	)

	allowed_procs = list(IS_CROWBAR = 100)

	min_duration = 20
	max_duration = 30

/datum/surgery_step/robotics/open_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.open == 1

/datum/surgery_step/robotics/open_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
	"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	 "<span class='notice'>You open the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 3

/datum/surgery_step/robotics/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")

///////////////////////////////////////////////////////////////
// Close Hatch Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/close_hatch
	step_name = "Close hatch"

	allowed_tools = list(
		/obj/item/surgical/retractor = 100,
		/obj/item/surgical/retractor_primitive = 75,
		/obj/item/material/kitchen/utensil = 50
	)

	allowed_procs = list(IS_CROWBAR = 100)

	min_duration = 20
	max_duration = 30

/datum/surgery_step/robotics/close_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.open && target_zone != O_MOUTH

/datum/surgery_step/robotics/close_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
	"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 0
	affected.germ_level = 0

/datum/surgery_step/robotics/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")

///////////////////////////////////////////////////////////////
// Brute Repair Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/repair_brute
	step_name = "Fix structure"

	allowed_tools = list(
		/obj/item/weldingtool = 100,
		/obj/item/pickaxe/plasmacutter = 50
	)

	min_duration = 20
	max_duration = 20

/datum/surgery_step/robotics/repair_brute/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(istype(tool, /obj/item/weldingtool))
			var/obj/item/weldingtool/welder = tool
			if(!welder.isOn() || !welder.remove_fuel(1,user))
				return 0
		return affected && affected.open == 3 && (affected.disfigured || affected.brute_dam > 0) && target_zone != O_MOUTH

/datum/surgery_step/robotics/repair_brute/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
	"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")
	..()

/datum/surgery_step/robotics/repair_brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes patching damage to [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You finish patching damage to [target]'s [affected.name] with \the [tool].</span>")
	affected.heal_damage(20, 0, 1, 1)
	affected.disfigured = 0

/datum/surgery_step/robotics/repair_brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>")
	target.apply_damage(rand(5,10), DAMAGE_TYPE_BURN, affected)

///////////////////////////////////////////////////////////////
// Burn Repair Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/repair_burn
	step_name = "Fix wiring"

	allowed_tools = list(
		/obj/item/stack/cable_coil = 100
	)

	min_duration = 20
	max_duration = 20

/datum/surgery_step/robotics/repair_burn/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(istype(tool, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = tool
			if(affected.burn_dam == 0)
				to_chat(user, "<span class='notice'>There are no burnt wires here!</span>")
				return SURGERY_FAILURE
			else
				if(!C.can_use(1))
					to_chat(user, "<span class='danger'>You need at least five cable pieces to repair this part.</span>") //usage amount made more consistent with regular cable repair
					return SURGERY_FAILURE
				else
					C.use(1)

		return affected && affected.open == 3 && (affected.disfigured || affected.burn_dam > 0) && target_zone != O_MOUTH

/datum/surgery_step/robotics/repair_burn/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
	"You begin to splice new cabling into [target]'s [affected.name].")
	..()

/datum/surgery_step/robotics/repair_burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes splicing cable into [target]'s [affected.name].</span>", \
	"<span class='notice'>You finishes splicing new cable into [target]'s [affected.name].</span>")
	affected.heal_damage(0, 20, 1, 1)
	affected.disfigured = 0

/datum/surgery_step/robotics/repair_burn/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user] causes a short circuit in [target]'s [affected.name]!</span>",
	"<span class='warning'>You cause a short circuit in [target]'s [affected.name]!</span>")
	target.apply_damage(rand(5,10), DAMAGE_TYPE_BURN, affected)

///////////////////////////////////////////////////////////////
// Robot Organ Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/fix_organ_robotic //For artificial organs
	step_name = "Repair systems"

	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,		\
	/obj/item/surgical/bonegel = 30, 		\
	)

	allowed_procs = list(IS_SCREWDRIVER = 100)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/robotics/fix_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected) return
	var/is_organ_damaged = 0
	for(var/obj/item/organ/I in affected.internal_organs)
		if(I.damage > 0 && (I.robotic >= ORGAN_ROBOT))
			is_organ_damaged = 1
			break
	return affected.open == 3 && is_organ_damaged

/datum/surgery_step/robotics/fix_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/organ/I in affected.internal_organs)
		if(I && I.damage > 0)
			if(I.robotic >= ORGAN_ROBOT)
				user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
				"You start mending the damage to [target]'s [I.name]'s mechanisms." )

	target.custom_pain("The pain in your [affected.name] is living hell!",1)
	..()

/datum/surgery_step/robotics/fix_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/organ/I in affected.internal_organs)
		if(I && I.damage > 0)
			if(I.robotic >= ORGAN_ROBOT)
				user.visible_message("<span class='notice'>[user] repairs [target]'s [I.name] with [tool].</span>", \
				"<span class='notice'>You repair [target]'s [I.name] with [tool].</span>" )
				I.revive(TRUE)

/datum/surgery_step/robotics/fix_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>")

	target.adjustToxLoss(5)
	affected.create_wound(WOUND_TYPE_CUT, 5)

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I)
			I.take_damage(rand(3,5),0)

///////////////////////////////////////////////////////////////
// Robot Organ Detaching Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/detatch_organ_robotic
	step_name = "Decouple system"

	allowed_tools = list(
	/obj/item/multitool = 100
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/robotics/detatch_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected && (affected.robotic >= ORGAN_ROBOT)))
		return 0
	if(affected.open < 3)
		return 0

	target.op_stage.current_organ = null

	var/list/attached_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/obj/item/organ/I = target.internal_organs_by_name[organ]
		if(I && !(I.status & ORGAN_CUT_AWAY) && I.parent_organ == target_zone)
			attached_organs |= organ

	var/organ_to_remove = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
	if(!organ_to_remove)
		return 0

	target.op_stage.current_organ = organ_to_remove

	return ..() && organ_to_remove

/datum/surgery_step/robotics/detatch_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to decouple [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start to decouple [target]'s [target.op_stage.current_organ] with \the [tool]." )
	..()

/datum/surgery_step/robotics/detatch_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has decoupled [target]'s [target.op_stage.current_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have decoupled [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/internal/I = target.internal_organs_by_name[target.op_stage.current_organ]
	if(I && istype(I))
		I.status |= ORGAN_CUT_AWAY

/datum/surgery_step/robotics/detatch_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, disconnecting \the [tool].</span>", \
	"<span class='warning'>Your hand slips, disconnecting \the [tool].</span>")

///////////////////////////////////////////////////////////////
// Robot Organ Attaching Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/attach_organ_robotic
	step_name = "Install system"

	allowed_tools = list(
	/obj/item/surgical/FixOVein = 100
	)

	min_duration = 100
	max_duration = 120

/datum/surgery_step/robotics/attach_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected && (affected.robotic >= ORGAN_ROBOT)))
		return 0
	if(affected.open < 3)
		return 0

	target.op_stage.current_organ = null

	var/list/removable_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/obj/item/organ/I = target.internal_organs_by_name[organ]
		if(I && (I.status & ORGAN_CUT_AWAY) && (I.robotic >= ORGAN_ROBOT) && I.parent_organ == target_zone)
			removable_organs |= organ

	var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in removable_organs
	if(!organ_to_replace)
		return 0

	target.op_stage.current_organ = organ_to_replace
	return ..()

/datum/surgery_step/robotics/attach_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].")
	..()

/datum/surgery_step/robotics/attach_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/I = target.internal_organs_by_name[target.op_stage.current_organ]
	if(I && istype(I))
		I.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/robotics/attach_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, disconnecting \the [tool].</span>", \
	"<span class='warning'>Your hand slips, disconnecting \the [tool].</span>")

///////////////////////////////////////////////////////////////
// MMI Insertion Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/install_mmi
	step_name = "Install MMI"

	allowed_tools = list(
	/obj/item/mmi = 100
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/robotics/install_mmi/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(target_zone != BP_HEAD)
		return

	var/obj/item/mmi/M = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected && affected.open == 3))
		return 0

	if(!istype(M))
		return 0

	if(!(affected.robotic >= ORGAN_ROBOT))
		to_chat(user, "<span class='danger'>You cannot install a computer brain into a meat skull.</span>")
		return SURGERY_FAILURE

	if(!target.should_have_organ("brain"))
		to_chat(user, "<span class='danger'>You're pretty sure [target.species.name_plural] don't normally have a brain.</span>")
		return SURGERY_FAILURE

	if(!isnull(target.internal_organs["brain"]))
		to_chat(user, "<span class='danger'>Your subject already has a brain.</span>")
		return SURGERY_FAILURE

	return 1

/datum/surgery_step/robotics/install_mmi/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
	"You start installing \the [tool] into [target]'s [affected.name].")
	..()

/datum/surgery_step/robotics/install_mmi/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has installed \the [tool] into [target]'s [affected.name].</span>", \
	"<span class='notice'>You have installed \the [tool] into [target]'s [affected.name].</span>")

	var/obj/item/mmi/M = tool
	var/obj/item/organ/internal/mmi_holder/holder = new(target, 1)
	target.internal_organs_by_name["brain"] = holder
	user.transfer_item_to_loc(tool, src, INV_OP_FORCE)
	holder.stored_mmi = tool
	holder.update_from_mmi()

	if(M.brainmob && M.brainmob.mind)
		M.brainmob.mind.transfer(target)
		target.languages = M.brainmob.languages

	spawn(0) //Name yourself on your own damn time
		var/new_name = target.name
		while(!new_name && target.client)
			if(!target) return
			var/try_name = input(target,"Pick a name for your new form!", "New Name", target.name)
			var/clean_name = sanitizeName(try_name)
			if(clean_name)
				var/okay = alert(target,"New name will be '[clean_name]', ok?", "Confirmation","Cancel","Ok")
				if(okay == "Ok")
					new_name = clean_name

		target.name = new_name
		target.real_name = target.name

/datum/surgery_step/robotics/install_mmi/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips.</span>", \
	"<span class='warning'>Your hand slips.</span>")

/**
 *! Install a Diona Nymph into a Nymph Mech
 */

/datum/surgery_step/robotics/install_nymph
	step_name = "Install Nymph"

	allowed_tools = list(
		/obj/item/holder/diona = 100
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/robotics/install_nymph/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(target_zone != BP_TORSO)
		return

	var/obj/item/holder/diona/N = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!(affected && affected.open == 3))
		return FALSE

	if(!istype(N))
		return FALSE

	if(!N.held_mob.client || N.held_mob.stat >= DEAD)
		to_chat(user, SPAN_DANGER("That nymph is not viable."))
		return SURGERY_FAILURE

	if(!(affected.robotic >= ORGAN_ROBOT))
		to_chat(user, SPAN_DANGER("You cannot install a nymph into a meat puppet.")) // No meat muppet for you.
		return SURGERY_FAILURE

	if(!(affected.model != "Skrellian Exoskeleton"))
		to_chat(user, SPAN_DANGER("You're fairly certain a nymph can't pilot a normal robot.<"))
		return SURGERY_FAILURE

	if(!target.should_have_organ("brain"))
		to_chat(user, SPAN_DANGER("You're pretty sure [target.species.name_plural] don't normally have a brain."))
		return SURGERY_FAILURE

	if(!isnull(target.internal_organs["brain"]))
		to_chat(user, SPAN_DANGER("Your subject already has a cephalon."))
		return SURGERY_FAILURE

	return TRUE

/datum/surgery_step/robotics/install_nymph/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("[user] starts setting \the [tool] into [target]'s [affected.name]."),
		SPAN_NOTICE("You start setting \the [tool] into [target]'s [affected.name]."),
		SPAN_HEAR("You hear something being placed inside something."),
	)
	..()

/datum/surgery_step/robotics/install_nymph/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		SPAN_NOTICE("[user] has installed \the [tool] into [target]'s [affected.name]."),
		SPAN_NOTICE("You have installed \the [tool] into [target]'s [affected.name]."),
	)

	var/obj/item/holder/diona/N = tool
	var/obj/item/organ/internal/brain/cephalon/cephalon = new(target, 1)
	target.internal_organs_by_name["brain"] = cephalon
	var/mob/living/carbon/alien/diona/D = N.held_mob
	user.drop_item_to_ground(tool, INV_OP_FORCE)

	if(D && D.mind)
		D.mind.transfer(target)
		target.languages |= D.languages

	qdel(D)

	target.set_species(/datum/species/diona)

	add_verb(target, /mob/living/carbon/human/proc/diona_split_nymph)
	add_verb(target, /mob/living/carbon/human/proc/regenerate)

	spawn(0) //Name yourself on your own damn time
		var/new_name = ""
		while(!new_name)
			if(!target)
				return
			var/try_name = input(target,"Pick a name for your new form!", "New Name", target.name)
			var/clean_name = sanitizeName(try_name)
			if(clean_name)
				var/okay = alert(target,"New name will be '[clean_name]', ok?", "Confirmation","Cancel","Ok")
				if(okay == "Ok")
					new_name = clean_name

		target.name = new_name
		target.real_name = target.name

/datum/surgery_step/robotics/install_nymph/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		SPAN_WARNING("[user]'s hand slips."),
		SPAN_WARNING("Your hand slips."),
	)
