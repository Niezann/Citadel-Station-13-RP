/**
 * mob inventory data goes in here.
 */
/datum/inventory
	//* Basics *//
	/// owning mob
	var/mob/owner

	//* Actions *//
	/// our action holder
	var/datum/action_holder/actions

	//* Inventory *//

	//* Caches *//
	/// cached overlays by slot id
	var/list/rendered_normal_overlays = list()
	/// cached overlays by slot id
	// todo: emissives
	// var/list/rendered_emissive_overlays = list()

/datum/inventory/New(mob/M)
	if(!istype(M))
		CRASH("no mob")
	owner = M
	/// no lazy-init for actions for now since items with actions are so common
	actions = new
	M.client?.action_drawer.register_holder(actions)

/datum/inventory/Destroy()
	QDEL_NULL(actions)
	owner = null
	return ..()

//* Rendering *//

/datum/inventory/proc/remove_slot_renders()
	var/list/transformed = list()
	for(var/slot_id in rendered_normal_overlays)
		transformed += rendered_normal_overlays[slot_id]
	owner.cut_overlay(transformed)

/datum/inventory/proc/reapply_slot_renders()
	// try not to dupe
	remove_slot_renders()
	var/list/transformed = list()
	for(var/slot_id in rendered_normal_overlays)
		transformed += rendered_normal_overlays[slot_id]
	owner.add_overlay(transformed)

/**
 * just update if a slot is visible
 */
/datum/inventory/proc/update_slot_visible(slot_id, cascade = TRUE)
	// resolve item
	var/obj/item/target = owner.item_by_slot_id(slot_id)

	// first, cascade incase we early-abort later
	if(cascade)
		var/datum/inventory_slot/slot = resolve_inventory_slot(slot_id)
		slot.cascade_render_visibility(owner, target)

	// check existing
	if(isnull(rendered_normal_overlays[slot_id]))
		return

	// remove overlay first incase it's already there
	owner.cut_overlay(rendered_normal_overlays[slot_id])

	// check if slot should render
	var/datum/inventory_slot/slot = resolve_inventory_slot(slot_id)
	if(!slot.should_render(owner, target))
		return

	// add overlay if it should
	owner.add_overlay(rendered_normal_overlays[slot_id])

/**
 * redo a slot's render
 */
/datum/inventory/proc/update_slot_render(slot_id, cascade = TRUE)
	var/datum/inventory_slot/slot = resolve_inventory_slot(slot_id)
	var/obj/item/target = owner.item_by_slot_id(slot_id)

	// first, cascade incase we early-abort later
	if(cascade)
		slot.cascade_render_visibility(owner, target)

	if(!slot.should_render(owner, target))
		remove_slot_render(slot_id)
		return

	if(isnull(target))
		remove_slot_render(slot_id)
		return

	var/bodytype = BODYTYPE_DEFAULT

	if(ishuman(owner))
		var/mob/living/carbon/human/casted_human = owner
		bodytype = casted_human.species.get_effective_bodytype(casted_human, target, slot_id)

	var/rendering_results = slot.render(owner, target, bodytype)
	if(islist(rendering_results)? !length(rendering_results) : isnull(rendering_results))
		remove_slot_render(slot_id)
		return

	set_slot_render(slot_id, rendering_results)

/datum/inventory/proc/remove_slot_render(slot_id)
	if(isnull(rendered_normal_overlays[slot_id]))
		return
	owner.cut_overlay(rendered_normal_overlays[slot_id])
	rendered_normal_overlays -= slot_id

/datum/inventory/proc/set_slot_render(slot_id, overlay)
	if(!isnull(rendered_normal_overlays[slot_id]))
		owner.cut_overlay(rendered_normal_overlays[slot_id])
	rendered_normal_overlays[slot_id] = overlay
	owner.add_overlay(overlay)

//* Queries *//

/**
 * returns list() of items with body_cover_flags
 */
/datum/inventory/proc/items_that_cover(cover_flags)
	if(cover_flags == NONE)
		return list()
	. = list()
	for(var/obj/item/I as anything in owner.get_equipped_items())
		if(I.body_cover_flags & cover_flags)
			. += I

//* Update Hooks *//

/**
 * Only called if mobility changed.
 */
/datum/inventory/proc/on_mobility_update()
	for(var/datum/action/action in actions.actions)
		action.update_button_availability()

// todo: redo things below, slowly

/**
 * handles the insertion
 * item can be moved or not moved before calling
 *
 * slot must be a typepath
 *
 * @return true/false based on if it worked
 */
/mob/proc/handle_abstract_slot_insertion(obj/item/I, slot, flags)
	if(!ispath(slot, /datum/inventory_slot/abstract))
		slot = resolve_inventory_slot(slot)?.type
		if(!ispath(slot, /datum/inventory_slot/abstract))
			stack_trace("invalid slot: [slot]")
		else if(slot != /datum/inventory_slot/abstract/put_in_hands)
			stack_trace("attempted usage of slot id in abstract insertion converted successfully")
	. = FALSE
	switch(slot)
		if(/datum/inventory_slot/abstract/hand/left)
			return put_in_left_hand(I, flags)
		if(/datum/inventory_slot/abstract/hand/right)
			return put_in_right_hand(I, flags)
		if(/datum/inventory_slot/abstract/put_in_belt)
			var/obj/item/held = item_by_slot_id(SLOT_ID_BELT)
			if(flags & INV_OP_FORCE)
				return held?.obj_storage?.insert(I, new /datum/event_args/actor(src), flags & INV_OP_SUPPRESS_SOUND)
			return held?.obj_storage?.auto_handle_interacted_insertion(I, new /datum/event_args/actor(src), flags & INV_OP_SUPPRESS_WARNING, flags & INV_OP_SUPPRESS_SOUND)
		if(/datum/inventory_slot/abstract/put_in_backpack)
			var/obj/item/held = item_by_slot_id(SLOT_ID_BACK)
			if(flags & INV_OP_FORCE)
				return held?.obj_storage?.insert(I, new /datum/event_args/actor(src), flags & INV_OP_SUPPRESS_SOUND)
			return held?.obj_storage?.auto_handle_interacted_insertion(I, new /datum/event_args/actor(src), flags & INV_OP_SUPPRESS_WARNING, flags & INV_OP_SUPPRESS_SOUND)
		if(/datum/inventory_slot/abstract/put_in_hands)
			return put_in_hands(I, flags)
		if(/datum/inventory_slot/abstract/put_in_storage, /datum/inventory_slot/abstract/put_in_storage_try_active)
			if(slot == /datum/inventory_slot/abstract/put_in_storage_try_active)
				// todo: redirection
				if(flags & INV_OP_FORCE)
					if(active_storage?.insert(I, new /datum/event_args/actor(src), flags & INV_OP_SUPPRESS_WARNING))
						return TRUE
				else
					if(active_storage?.auto_handle_interacted_insertion(I, new /datum/event_args/actor(src), flags & INV_OP_SUPPRESS_WARNING, flags & INV_OP_SUPPRESS_SOUND))
						return TRUE
			for(var/obj/item/held in get_equipped_items_in_slots(list(
				SLOT_ID_BELT,
				SLOT_ID_BACK,
				SLOT_ID_UNIFORM,
				SLOT_ID_SUIT,
				SLOT_ID_LEFT_POCKET,
				SLOT_ID_RIGHT_POCKET
			)) + get_held_items())
				if(isnull(held?.obj_storage))
					continue
				if(flags & INV_OP_FORCE)
					return held.obj_storage.insert(I, new /datum/event_args/actor(src), flags & INV_OP_SUPPRESS_SOUND)
				return held.obj_storage.auto_handle_interacted_insertion(I, new /datum/event_args/actor(src), flags & INV_OP_SUPPRESS_WARNING, flags & INV_OP_SUPPRESS_SOUND)
			return FALSE
		if(/datum/inventory_slot/abstract/attach_as_accessory)
			for(var/obj/item/clothing/C in get_equipped_items())
				if(C.attempt_attach_accessory(I))
					return TRUE
			return FALSE
		else
			CRASH("Invalid abstract slot [slot]")

/**
 * handles internal logic of unequipping an item
 *
 * @params
 * - I - item
 * - flags - inventory operation hint bitfield, see defines
 * - newloc - where to transfer to. null for nullspace, FALSE for don't transfer
 * - user - can be null - person doing the removals
 *
 * @return TRUE/FALSE for success
 */
/mob/proc/_unequip_item(obj/item/I, flags, newloc, mob/user = src)
	PROTECTED_PROC(TRUE)
	if(!I)
		return TRUE

	var/hand = get_held_index(I)
	var/old
	if(hand)
		if(!can_unequip(I, SLOT_ID_HANDS, flags, user))
			return FALSE
		_unequip_held(I, TRUE)
		I.unequipped(src, SLOT_ID_HANDS, flags)
		old = SLOT_ID_HANDS
	else
		if(!I.worn_slot)
			stack_trace("tried to unequip an item without current equipped slot.")
			I.worn_slot = _slot_by_item(I)
		if(!can_unequip(I, I.worn_slot, flags, user))
			return FALSE
		old = I.worn_slot
		_unequip_slot(I.worn_slot, flags)
		I.unequipped(src, I.worn_slot, flags)
		handle_item_denesting(I, old, flags, user)

	// this qdeleted catches unequipped() deleting the item.
	. = QDELETED(I)? FALSE : TRUE

	log_inventory("[key_name(src)] unequipped [I] from [old].")

	if(I)
		// todo: better rendering that takes observers into account
		if(client)
			client.screen -= I
			I.screen_loc = null
		//! at some point we should have /pre_dropped and /pre_pickup, because dropped should logically come after move.
		if(I.dropped(src, flags, newloc) == ITEM_RELOCATED_BY_DROPPED)
			. = FALSE
		else if(QDELETED(I))
			// this check RELIES on dropped() being the first if
			// make sure you don't blindly move it!!
			// this is meant to catch any potential deletions dropped can cause.
			. = FALSE
		else
			if(!(I.item_flags & ITEM_DROPDEL))
				if(newloc == null)
					I.moveToNullspace()
				else if(newloc != FALSE)
					I.forceMove(newloc)

/mob/proc/handle_item_denesting(obj/item/I, old_slot, flags, mob/user)
	// if the item was inside something,
	if(I.worn_inside)
		var/obj/item/over = I.worn_over
		var/obj/item/inside = I.worn_inside
		// if we were inside something we WEREN'T the top level item
		// collapse the links
		inside.worn_over = over
		if(over)
			over.worn_inside = inside
		I.worn_over = null
		I.worn_inside = null
		// call procs to inform things
		inside.equip_on_worn_over_remove(src, old_slot, user, I, flags)
		if(over)
			I.equip_on_worn_over_remove(src, old_slot, user, over, flags)

		// now we're free to forcemove later
	// if the item wasn't but was worn over something, there's more complicated methods required
	else if(I.worn_over)
		var/obj/item/over = I.worn_over
		I.worn_over = null
		I.equip_on_worn_over_remove(src, old_slot, user, I.worn_over, flags)
		// I is free to be forcemoved now, but the old object needs to be put back on
		over.worn_hook_suppressed = TRUE
		over.forceMove(src)
		over.worn_hook_suppressed = FALSE
		// put it back in the slot
		_equip_slot(over, old_slot, flags)
		// put it back on the screen
		over.hud_layerise()
		position_hud_item(over, old_slot)
		client?.screen |= over

/**
 * checks if we can unequip an item
 *
 * Preconditions: The item is either equipped already, or isn't equipped.
 *
 * @return TRUE/FALSE
 *
 * @params
 * - I - item
 * - slot - slot we're unequipping from - can be null
 * - flags - inventory operation hint bitfield, see defines
 * - user - stripper - can be null
 */
/mob/proc/can_unequip(obj/item/I, slot, flags, mob/user = src)
	// destroyed IS allowed to call these procs
	if(I && QDELETED(I) && !QDESTROYING(I))
		to_chat(user, SPAN_DANGER("A deleted [I] was checked in can_unequip(). Report this entire line to coders immediately. Debug data: [I] ([REF(I)]) slot [slot] flags [flags] user [user]"))
		to_chat(user, SPAN_DANGER("can_unequip will return TRUE to allow you to drop the item, but expect potential glitches!"))
		return TRUE

	if(!slot)
		slot = slot_id_by_item(I)

	if(!(flags & INV_OP_FORCE) && HAS_TRAIT(I, TRAIT_ITEM_NODROP))
		if(!(flags & INV_OP_SUPPRESS_WARNING))
			var/datum/inventory_slot/slot_meta = resolve_inventory_slot(slot)
			to_chat(user, SPAN_WARNING("[I] is stubbornly stuck [slot_meta.display_preposition] your [slot_meta.display_name]!"))
		return FALSE

	var/blocked_by
	if((blocked_by = inventory_slot_reachability_conflict(I, slot, user)) && !(flags & (INV_OP_FORCE | INV_OP_IGNORE_REACHABILITY)))
		if(!(flags & INV_OP_SUPPRESS_WARNING))
			to_chat(user, SPAN_WARNING("\the [blocked_by] is in the way!"))
		return FALSE

	// lastly, check item's opinion
	if(!I.can_unequip(src, slot, user, flags))
		return FALSE

	return TRUE

/**
 * checks if we can equip an item to a slot
 *
 * Preconditions: The item will either be equipped on us already, or not yet equipped.
 *
 * @return TRUE/FALSE
 *
 * @params
 * - I - item
 * - slot - slot ID
 * - flags - inventory operation hint bitfield, see defines
 * - user - user trying to equip that thing to us there - can be null
 * - denest_to - the old slot we're leaving if called from handle_item_reequip. **extremely** snowflakey
 *
 * todo: refactor nesting to not require this shit
 */
/mob/proc/can_equip(obj/item/I, slot, flags, mob/user, denest_to)
	// let's NOT.
	if(I && QDELETED(I))
		to_chat(user, SPAN_DANGER("A deleted [I] was checked in can_equip(). Report this entire line to coders immediately. Debug data: [I] ([REF(I)]) slot [slot] flags [flags] user [user]"))
		to_chat(user, SPAN_DANGER("can_equip will now attempt to prevent the deleted item from being equipped. There should be no glitches."))
		return FALSE

	var/datum/inventory_slot/slot_meta = resolve_inventory_slot(slot)
	var/self_equip = user == src
	if(!slot_meta)
		. = FALSE
		CRASH("Failed to resolve to slot datm.")

	if(slot_meta.inventory_slot_flags & INV_SLOT_IS_ABSTRACT)
		// special handling: make educated guess, defaulting to yes
		switch(slot_meta.type)
			if(/datum/inventory_slot/abstract/hand/left)
				return (flags & INV_OP_FORCE) || !get_left_held_item()
			if(/datum/inventory_slot/abstract/hand/right)
				return (flags & INV_OP_FORCE) || !get_right_held_item()
			if(/datum/inventory_slot/abstract/put_in_backpack)
				var/obj/item/thing = item_by_slot_id(SLOT_ID_BACK)
				return thing?.obj_storage?.can_be_inserted(I, new /datum/event_args/actor(user), TRUE)
			if(/datum/inventory_slot/abstract/put_in_belt)
				var/obj/item/thing = item_by_slot_id(SLOT_ID_BACK)
				return thing?.obj_storage?.can_be_inserted(I, new /datum/event_args/actor(user), TRUE)
			if(/datum/inventory_slot/abstract/put_in_hands)
				return (flags & INV_OP_FORCE) || !hands_full()
		return TRUE

	if(!inventory_slot_bodypart_check(I, slot, user, flags) && !(flags & INV_OP_FORCE))
		return FALSE

	var/conflict_result = inventory_slot_conflict_check(I, slot, flags)
	var/obj/item/to_wear_over

	if((flags & INV_OP_IS_FINAL_CHECK) && conflict_result && (slot != SLOT_ID_HANDS))
		// try to fit over
		var/obj/item/conflicting = item_by_slot_id(slot)
		if(conflicting)
			// there's something there
			var/can_fit_over = I.equip_worn_over_check(src, slot, user, conflicting, flags)
			if(can_fit_over)
				conflict_result = CAN_EQUIP_SLOT_CONFLICT_NONE
				to_wear_over = conflicting
				// ! DANGER: snowflake time
				// take it out of the slot
				_unequip_slot(slot, flags | INV_OP_NO_LOGIC | INV_OP_NO_UPDATE_ICONS)
				// recheck
				conflict_result = inventory_slot_conflict_check(I, slot)
				// put it back in incase something else breaks
				_equip_slot(conflicting, slot, flags | INV_OP_NO_LOGIC | INV_OP_NO_UPDATE_ICONS)

	switch(conflict_result)
		if(CAN_EQUIP_SLOT_CONFLICT_HARD)
			if(!(flags & INV_OP_SUPPRESS_WARNING))
				to_chat(user, SPAN_WARNING("[self_equip? "You" : "They"] are already [slot_meta.display_plural? "holding too many things" : "wearing something"] [slot_meta.display_preposition] [self_equip? "your" : "their"] [slot_meta.display_name]."))
			return FALSE
		if(CAN_EQUIP_SLOT_CONFLICT_SOFT)
			if(!(flags & INV_OP_FORCE))
				if(!(flags & INV_OP_SUPPRESS_WARNING))
					to_chat(user, SPAN_WARNING("[self_equip? "You" : "They"] are already [slot_meta.display_plural? "holding too many things" : "wearing something"] [slot_meta.display_preposition] [self_equip? "your" : "their"] [slot_meta.display_name]."))
				return FALSE

	if(!inventory_slot_semantic_conflict(I, slot, user) && !(flags & INV_OP_FORCE))
		if(!(flags & INV_OP_SUPPRESS_WARNING))
			to_chat(user, SPAN_WARNING("[I] doesn't fit there."))
		return FALSE

	var/blocked_by

	if((blocked_by = inventory_slot_reachability_conflict(I, slot, user)) && !(flags & (INV_OP_FORCE | INV_OP_IGNORE_REACHABILITY)))
		if(!(flags & INV_OP_SUPPRESS_WARNING))
			to_chat(user, SPAN_WARNING("\the [blocked_by] is in the way!"))
		return FALSE

	// lastly, check item's opinion
	if(!I.can_equip(src, slot, user, flags))
		return FALSE

	// we're the final check - side effects ARE allowed
	if((flags & INV_OP_IS_FINAL_CHECK) && to_wear_over)
		//! Note: this means that can_unequip is NOT called for to wear over.
		//! This is intentional, but very, very sonwflakey.
		to_wear_over.worn_inside = I
		// setting worn inside first disallows equip/unequip from triggering
		to_wear_over.forceMove(I)
		// check we don't have something already (wtf)
		if(I.worn_over)
			handle_item_denesting(I, denest_to, flags, user)
		// set the other way around
		I.worn_over = to_wear_over
		// tell it we're inserting the old item
		I.equip_on_worn_over_insert(src, slot, user, to_wear_over, flags)
		// take the old item off our screen
		client?.screen -= to_wear_over
		to_wear_over.screen_loc = null
		to_wear_over.hud_unlayerise()
		// we don't call slot re-equips here because the equip proc does this for us

	return TRUE

/**
 * checks if we are missing the bodypart for a slot
 * return FALSE if we are missing, or TRUE if we're not
 *
 * this proc should give the feedback of what's missing!
 */
/mob/proc/inventory_slot_bodypart_check(obj/item/I, slot, mob/user, flags)
	return TRUE

/**
 * drop items if a bodypart is missing
 */
/mob/proc/reconsider_inventory_slot_bodypart(bodypart)
	// todo: this and the above function should be on the slot datums.
	var/list/obj/item/affected
	switch(bodypart)
		if(BP_HEAD)
			affected = items_by_slot(
				SLOT_ID_HEAD,
				SLOT_ID_LEFT_EAR,
				SLOT_ID_RIGHT_EAR,
				SLOT_ID_MASK,
				SLOT_ID_GLASSES
			)
		if(BP_GROIN, BP_TORSO)
			affected = items_by_slot(
				SLOT_ID_BACK,
				SLOT_ID_BELT,
				SLOT_ID_SUIT,
				SLOT_ID_SUIT_STORAGE,
				SLOT_ID_RIGHT_POCKET,
				SLOT_ID_LEFT_POCKET,
				SLOT_ID_UNIFORM
			)
		if(BP_L_ARM, BP_L_HAND, BP_R_ARM, BP_R_HAND)
			affected = items_by_slot(
				SLOT_ID_HANDCUFFED,
				SLOT_ID_GLOVES
			)
		if(BP_L_LEG, BP_L_FOOT, BP_R_LEG, BP_R_FOOT)
			affected = items_by_slot(
				SLOT_ID_LEGCUFFED,
				SLOT_ID_SHOES
			)
	if(!affected)
		return
	else if(!islist(affected))
		affected = list(affected)
	for(var/obj/item/I as anything in affected)
		if(!inventory_slot_bodypart_check(I, I.worn_slot, null, INV_OP_SILENT))
			drop_item_to_ground(I, INV_OP_SILENT)

/**
 * checks for slot conflict
 */
/mob/proc/inventory_slot_conflict_check(obj/item/I, slot, flags)
	var/obj/item/conflicting = _item_by_slot(slot)
	if(conflicting)
		if((flags & (INV_OP_CAN_DISPLACE | INV_OP_IS_FINAL_CHECK)) == (INV_OP_CAN_DISPLACE | INV_OP_IS_FINAL_CHECK))
			drop_item_to_ground(conflicting, INV_OP_FORCE)
			if(_item_by_slot(slot))
				return CAN_EQUIP_SLOT_CONFLICT_HARD
		else
			return CAN_EQUIP_SLOT_CONFLICT_HARD
	switch(slot)
		if(SLOT_ID_LEFT_EAR, SLOT_ID_RIGHT_EAR)
			if(I.slot_flags & SLOT_TWOEARS)
				if(_item_by_slot(SLOT_ID_LEFT_EAR) || _item_by_slot(SLOT_ID_RIGHT_EAR))
					return CAN_EQUIP_SLOT_CONFLICT_SOFT
			else
				var/obj/item/left_ear = _item_by_slot(SLOT_ID_LEFT_EAR)
				var/obj/item/right_ear = _item_by_slot(SLOT_ID_RIGHT_EAR)
				if(left_ear && left_ear != INVENTORY_SLOT_DOES_NOT_EXIST && left_ear != I && left_ear.slot_flags & SLOT_TWOEARS)
					return CAN_EQUIP_SLOT_CONFLICT_SOFT
				else if(right_ear && right_ear != INVENTORY_SLOT_DOES_NOT_EXIST && right_ear != I && right_ear.slot_flags & SLOT_TWOEARS)
					return CAN_EQUIP_SLOT_CONFLICT_SOFT
	return CAN_EQUIP_SLOT_CONFLICT_NONE

/**
 * checks if you can reach a slot
 * return null or the first item blocking
 */
/mob/proc/inventory_slot_reachability_conflict(obj/item/I, slot, mob/user)
	return null

/**
 * semantic check - should this item fit here? slot flag checks/etc should go in here.
 *
 * return TRUE if conflicting, otherwise FALSE
 */
/mob/proc/inventory_slot_semantic_conflict(obj/item/I, datum/inventory_slot/slot, mob/user)
	. = FALSE
	slot = resolve_inventory_slot(slot)
	return slot._equip_check(I, src, user)

/**
 * handles internal logic of equipping an item
 *
 * @params
 * - I - item to equip
 * - flags - inventory operation hint flags, see defines
 * - slot - slot to equip it to
 * - user - user trying to put it on us
 *
 * @return TRUE/FALSE on success
 */
/mob/proc/_equip_item(obj/item/I, flags, slot, mob/user = src)
	PROTECTED_PROC(TRUE)

	if(!I)		// how tf would we put on "null"?
		return FALSE

	// resolve slot
	var/datum/inventory_slot/slot_meta = resolve_inventory_slot(slot)
	if(slot_meta.inventory_slot_flags & INV_SLOT_IS_ABSTRACT)
		// if it's abstract, we go there directly - do not use can_equip as that will just guess.
		return handle_abstract_slot_insertion(I, slot, flags)

	// slots must have IDs.
	ASSERT(!isnull(slot_meta.id))
	// convert to ID after abstract slot checks
	slot = slot_meta.id

	var/old_slot = slot_id_by_item(I)

	if(old_slot)
		. = _handle_item_reequip(I, slot, old_slot, flags, user)
		if(!.)
			return

		log_inventory("[key_name(src)] moved [I] from [old_slot] to [slot].")
	else
		if(!can_equip(I, slot, flags | INV_OP_IS_FINAL_CHECK, user))
			return FALSE

		var/atom/oldLoc = I.loc
		if(I.loc != src)
			I.forceMove(src)
		if(I.loc != src)
			// UH OH, SOMEONE MOVED US
			log_inventory("[key_name(src)] failed to equip [I] to slot (loc sanity failed).")
			// UH OH x2, WE GOT WORN OVER SOMETHING
			if(I.worn_over)
				handle_item_denesting(I, slot, INV_OP_FATAL, user)
			return FALSE

		_equip_slot(I, slot, flags)

		log_inventory("[key_name(src)] equipped [I] to [slot].")

		// TODO: HANDLE DELETIONS IN PICKUP AND EQUIPPED PROPERLY
		I.pickup(src, flags, oldLoc)
		I.equipped(src, slot, flags)

	if(I.zoom)
		I.zoom()

	return TRUE

/**
 * checks if we already have something in our inventory
 * if so, this will try to shift the slots over, calling equipped/unequipped automatically
 *
 * INV_OP_FORCE will allow ignoring can unequip.
 *
 * return true/false based on if we succeeded
 */
/mob/proc/_handle_item_reequip(obj/item/I, slot, old_slot, flags, mob/user = src)
	ASSERT(slot)
	if(!old_slot)
		// DO NOT USE _slot_by_item - at this point, the item has already been var-set into the new slot!
		// slot_id_by_item however uses cached values still!
		old_slot = slot_id_by_item(I)
		if(!old_slot)
			// still not there, wasn't already in inv
			return FALSE
	// this IS a slot shift!
	. = old_slot
	if((slot == old_slot) && (slot != SLOT_ID_HANDS))
		// lol we're done (unless it was hands)
		return TRUE
	if(slot == SLOT_ID_HANDS)
		// if we're going into hands,
		// just check can unequip
		if(!can_unequip(I, old_slot, flags, user))
			// check can unequip
			return FALSE
		// call procs
		if(old_slot == SLOT_ID_HANDS)
			_unequip_held(I, flags)
		else
			_unequip_slot(old_slot, flags)
		I.unequipped(src, old_slot, flags)
		// sigh
		handle_item_denesting(I, old_slot, flags, user)
		// TODO: HANDLE DELETIONS ON EQUIPPED PROPERLY, INCLUDING ON HANDS
		// ? we don't do this on hands, hand procs do it
		// _equip_slot(I, slot, update_icons)
		I.equipped(src, slot, flags)
		log_inventory("[key_name(src)] moved [I] from [old_slot] to hands.")
		// hand procs handle rest
		return TRUE
	else
		// else, this gets painful
		if(!can_unequip(I, old_slot, flags, user))
			return FALSE
		if(!can_equip(I, slot, flags | INV_OP_IS_FINAL_CHECK, user, old_slot))
			return FALSE
		// ?if it's from hands, hands aren't a slot.
		if(old_slot == SLOT_ID_HANDS)
			_unequip_held(I, flags)
		else
			_unequip_slot(old_slot, flags)
		I.unequipped(src, old_slot, flags)
		// TODO: HANDLE DELETIONS ON EQUIPPED PROPERLY
		// sigh
		_equip_slot(I, slot, flags)
		I.equipped(src, slot, flags)
		log_inventory("[key_name(src)] moved [I] from [old_slot] to [slot].")
		return TRUE

/**
 * handles removing an item from our hud
 *
 * some things call us from outside inventory code. this is shitcode and shouldn't be propageted.
 */
/mob/proc/_handle_inventory_hud_remove(obj/item/I)
	if(client)
		client.screen -= I
	I.screen_loc = null

/**
 * handles adding an item or updating an item to our hud
 */
/mob/proc/_handle_inventory_hud_update(obj/item/I, slot)
	var/datum/inventory_slot/meta = resolve_inventory_slot(slot)
	I.screen_loc = meta.hud_position
	if(client)
		client.screen |= I

/**
 * get all equipped items
 *
 * @params
 * include_inhands - include held items too?
 * include_restraints - include restraints too?
 */
/mob/proc/get_equipped_items(include_inhands, include_restraints)
	return get_held_items() + _get_all_slots(include_restraints)

/**
 * wipe our inventory
 *
 * @params
 * include_inhands - include held items too?
 * include_restraints - include restraints too?
 */
/mob/proc/delete_inventory(include_inhands = TRUE, include_restraints = TRUE)
	for(var/obj/item/I as anything in get_equipped_items(include_inhands, include_restraints))
		qdel(I)

/**
 * drops everything in our inventory
 *
 * @params
 * - include_inhands - include held items too?
 * - include_restraints - include restraints too?
 * - force - ignore nodrop and all that
 */
/mob/proc/drop_inventory(include_inhands = TRUE, include_restraints = TRUE, force = TRUE)
	for(var/obj/item/I as anything in get_equipped_items(include_inhands, include_restraints))
		drop_item_to_ground(I, INV_OP_SILENT | INV_OP_FLUFFLESS | (force? INV_OP_FORCE : NONE))

	// todo: handle what happens if dropping something requires a logic thing
	// e.g. dropping jumpsuit makes it impossible to transfer a belt since it
	// de-equipped from the jumpsuit

/mob/proc/transfer_inventory_to_loc(atom/newLoc, include_inhands = TRUE, include_restraints = TRUE, force = TRUE)
	for(var/obj/item/I as anything in get_equipped_items(include_inhands, include_restraints))
		transfer_item_to_loc(I, newLoc, INV_OP_SILENT | INV_OP_FLUFFLESS | (force? INV_OP_FORCE : NONE))
	// todo: handle what happens if dropping something requires a logic thing
	// e.g. dropping jumpsuit makes it impossible to transfer a belt since it
	// de-equipped from the jumpsuit

/**
 * gets the primary item in a slot
 * null if not in inventory. inhands don't count as inventory here, use held item procs.
 */
/mob/proc/item_by_slot_id(slot)
	return _item_by_slot(slot)	// why the needless indirection? so people don't override this for slots!

/**
 * gets the primary item and nested items (e.g. gloves, magboots, accessories) in a slot
 * null if not in inventory, otherwise list
 * inhands do not count as inventory
 */
/mob/proc/items_by_slot(slot)
	var/obj/item/I = _item_by_slot(slot)
	if(!I)
		return list()
	I = I._inv_return_attached()
	return islist(I)? I : list(I)

/**
 * returns if we have something equipped - the slot if it is, null if not
 *
 * SLOT_ID_HANDS if in hands
 */
/mob/proc/is_in_inventory(obj/item/I)
	return (I?.worn_mob() == src) && I.worn_slot
	// we use entirely cached vars for speed.
	// if this returns bad data well fuck you, don't break equipped()/unequipped().

/**
 * returns if an item is in inventory (equipped) rather than hands
 */
/mob/proc/is_wearing(obj/item/I)
	var/slot = is_in_inventory(I)
	return slot && (slot != SLOT_ID_HANDS)

/**
 * get slot of item if it's equipped.
 * null if not in inventory. SLOT_HANDS if held.
 */
/mob/proc/slot_id_by_item(obj/item/I)
	return is_in_inventory(I) || null		// short circuited to that too
									// if equipped/unequipped didn't set worn_slot well jokes on you lmfao

/mob/proc/_equip_slot(obj/item/I, slot, flags)
	SHOULD_NOT_OVERRIDE(TRUE)
	. = _set_inv_slot(slot, I, flags) != INVENTORY_SLOT_DOES_NOT_EXIST

/mob/proc/_unequip_slot(slot, flags)
	SHOULD_NOT_OVERRIDE(TRUE)
	. = _set_inv_slot(slot, null, flags) != INVENTORY_SLOT_DOES_NOT_EXIST

/mob/proc/_unequip_held(obj/item/I, flags)
	return

/mob/proc/has_slot(id)
	SHOULD_NOT_OVERRIDE(TRUE)
	return _item_by_slot(id) != INVENTORY_SLOT_DOES_NOT_EXIST

// todo: both of these below procs needs optimization for when we need the datum anyways, to avoid two lookups

/mob/proc/semantically_has_slot(id)
	return has_slot(id) && _semantic_slot_id_check(id)

/mob/proc/get_inventory_slot_ids(semantic, sorted)
	// get all
	if(sorted)
		. = list()
		for(var/id as anything in GLOB.inventory_slot_meta)
			if(!semantically_has_slot(id))
				continue
			. += id
		return
	else
		. = _get_inventory_slot_ids()
	// check if we should filter
	if(!semantic)
		return
	. = _get_inventory_slot_ids()
	for(var/id in .)
		if(!_semantic_slot_id_check(id))
			. -= id

/**
 * THESE PROCS MUST BE OVERRIDDEN FOR NEW SLOTS ON MOBS
 * yes, i managed to shove all basic behaviors that needed overriding into 5-6 procs
 * you're
 * welcome.
 *
 * These are UNSAFE PROCS.
 *
 * oh and can_equip_x* might need overriding for complex mobs like humans but frankly
 * sue me, there's no better way right now.
 */

/**
 * sets a slot to icon or null
 *
 * some behaviors may be included other than update icons
 * even update icons is unpreferred but we're stuck with this for now.
 *
 * todo: logic should be moved out of the proc, but where?
 *
 * @params
 * slot - slot to set
 * I - item or null
 * update_icons - update icons immediately?
 * logic - apply logic like dropping stuff from pockets when unequippiing a jumpsuit imemdiately?
 */
/mob/proc/_set_inv_slot(slot, obj/item/I, flags)
	PROTECTED_PROC(TRUE)
	. = INVENTORY_SLOT_DOES_NOT_EXIST
	CRASH("Attempting to set inv slot of [slot] to [I] went to base /mob. You probably had someone assigning to a nonexistant slot!")

/**
 * ""expensive"" proc that scans for the real slot of an item
 * usually used when safety checks detect something is amiss
 */
/mob/proc/_slot_by_item(obj/item/I)
	PROTECTED_PROC(TRUE)

/**
 * doubles as slot detection
 * returns -1 if no slot
 * YES, MAGIC VALUE BUT SOLE USER IS 20 LINES ABOVE, SUE ME.
 */
/mob/proc/_item_by_slot(slot)
	PROTECTED_PROC(TRUE)
	return INVENTORY_SLOT_DOES_NOT_EXIST

/mob/proc/_get_all_slots(include_restraints)
	PROTECTED_PROC(TRUE)
	return list()

/**
 * return all slot ids we implement
 */
/mob/proc/_get_inventory_slot_ids()
	PROTECTED_PROC(TRUE)
	return list()

/**
 * override this if you need to make a slot not semantically exist
 * useful for other species that don't have a slot so you don't have jumpsuit requirements apply
 */
/mob/proc/_semantic_slot_id_check(id)
	PROTECTED_PROC(TRUE)
	return TRUE
