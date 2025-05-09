
var/global/BSACooldown = 0
var/global/floorIsLava = 0


////////////////////////////////
/proc/message_admins(msg)
	msg = SPAN_ADMIN("<span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span>")
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg,
		confidential = TRUE)

/proc/msg_admin_attack(var/text) //Toggleable Attack Messages
	return
	// var/rendered = "<span class='log_message><span class='prefix'>ATTACK:</span> <span class='message'>[text]</span></span>"
	// for(var/client/C in GLOB.admins)
	// 	if((R_ADMIN|R_MOD) & C.holder.rights)
	// 		if(C.get_preference_toggle(/datum/client_preference/mod/show_attack_logs))
	// 			var/msg = rendered
	// 			to_chat(C, msg)

/proc/admin_notice(var/message, var/rights)
	for(var/mob/M in GLOB.mob_list)
		if(check_rights(rights, 0, M))
			to_chat(M, message)

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/body = "<html><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += "\[<A href='?src=\ref[src];editrights=show'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\]"

	if(istype(M, /mob/new_player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?src=\ref[src];revive=\ref[M]'>Heal</A>\] "

	if(M.client)
		body += "<br><b>First connection:</b> [M.client.player.player_age] days ago"
		body += "<br><b>BYOND account created:</b> [M.client.persistent.account_join]"
		body += "<br><b>BYOND account age (days):</b> [M.client.persistent.account_age]"

	body += {"
		<br><br>\[
		<a href='?_src_=vars;Vars=\ref[M]'>VV</a> -
		<a href='?src=\ref[src];traitor=\ref[M]'>TP</a> -
		<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a> -
		<a href='?src=\ref[src];subtlemessage=\ref[M]'>SM</a> -
		[admin_jump_link(M, src)]\] <br>
		<b>Mob type:</b> [M.type]<br>
		<b>Inactivity time:</b> [M.client ? "[M.client.inactivity/600] minutes" : "Logged out"]<br/><br/>
		<A href='?src=\ref[src];boot2=\ref[M]'>Kick</A> |
		<A href='?src=\ref[src];newban=\ref[M]'>Ban</A> |
		<A href='?src=\ref[src];jobban2=\ref[M]'>Jobban</A> |
		<A href='?src=\ref[src];oocban=[M.ckey]'>[is_role_banned_ckey(M.ckey, role = BAN_ROLE_OOC)? "<font color='red'>OOC Ban</font>" : "OOC Ban"]</A> |
		<A href='?src=\ref[src];notes=show;mob=\ref[M]'>Notes</A>
	"}

	if(M.client)
		body += "| <A HREF='?src=\ref[src];sendtoprison=\ref[M]'>Prison</A> | "
		var/muted = M.client.prefs.muted
		body += {"<br><b>Mute: </b>
			\[<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC)?"red":"blue"]'>IC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a>\]
			(<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL)?"red":"blue"]'>toggle all</font></a>)
		"}

	body += {"<br><br>
		<A href='?src=\ref[src];jumpto=\ref[M]'><b>Jump to</b></A> |
		<A href='?src=\ref[src];getmob=\ref[M]'>Get</A> |
		<A href='?src=\ref[src];sendmob=\ref[M]'>Send To</A>
		<br><br>
		[check_rights(R_ADMIN|R_MOD,0) ? "<A href='?src=\ref[src];traitor=\ref[M]'>Traitor panel</A> | " : "" ]
		<A href='?src=\ref[src];narrateto=\ref[M]'>Narrate to</A> |
		<A href='?src=\ref[src];subtlemessage=\ref[M]'>Subtle message</A>
	"}

	if (M.client)
		if(!istype(M, /mob/new_player))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Monkey
			if(issmall(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='?src=\ref[src];monkeyone=\ref[M]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?src=\ref[src];corgione=\ref[M]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += {"<A href='?src=\ref[src];makeai=\ref[M]'>Make AI</A> |
					<A href='?src=\ref[src];makerobot=\ref[M]'>Make Robot</A> |
					<A href='?src=\ref[src];makealien=\ref[M]'>Make Alien</A>
				"}

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Re-Animalize</A> | "
			else
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Animalize</A> | "

			// DNA2 - Admin Hax
			if(M.dna && iscarbon(M))
				body += "<br><br>"
				body += "<b>DNA Blocks:</b><br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
				var/bname
				for(var/block=1;block<=DNA_SE_LENGTH;block++)
					if(((block-1)%5)==0)
						body += "</tr><tr><th>[block-1]</th>"
					bname = assigned_blocks[block]
					body += "<td>"
					if(bname)
						var/bstate=M.dna.GetSEState(block)
						var/bcolor="[(bstate)?"#006600":"#ff0000"]"
						body += "<A href='?src=\ref[src];togmutate=\ref[M];block=[block]' style='color:[bcolor];'>[bname]</A><sub>[block]</sub>"
					else
						body += "[block]"
					body+="</td>"
				body += "</tr></table>"

			body += {"<br><br>
				<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</font><br>
				<A href='?src=\ref[src];simplemake=observer;mob=\ref[M]'>Observer</A> |
				\[ Xenos: <A href='?src=\ref[src];simplemake=larva;mob=\ref[M]'>Larva</A>
				<A href='?src=\ref[src];simplemake=human;species=Xenomorph Drone;mob=\ref[M]'>Drone</A>
				<A href='?src=\ref[src];simplemake=human;species=Xenomorph Hunter;mob=\ref[M]'>Hunter</A>
				<A href='?src=\ref[src];simplemake=human;species=Xenomorph Sentinel;mob=\ref[M]'>Sentinel</A>
				<A href='?src=\ref[src];simplemake=human;species=Xenomorph Queen;mob=\ref[M]'>Queen</A> \] |
				\[ Crew: <A href='?src=\ref[src];simplemake=human;mob=\ref[M]'>Human</A>
				<A href='?src=\ref[src];simplemake=human;species=Unathi;mob=\ref[M]'>Unathi</A>
				<A href='?src=\ref[src];simplemake=human;species=Tajaran;mob=\ref[M]'>Tajaran</A>
				<A href='?src=\ref[src];simplemake=human;species=Skrell;mob=\ref[M]'>Skrell</A> \] | \[
				<A href='?src=\ref[src];simplemake=nymph;mob=\ref[M]'>Nymph</A>
				<A href='?src=\ref[src];simplemake=human;species='Diona';mob=\ref[M]'>Diona</A> \] |
				\[ slime: <A href='?src=\ref[src];simplemake=slime;mob=\ref[M]'>Baby</A>,
				<A href='?src=\ref[src];simplemake=adultslime;mob=\ref[M]'>Adult</A> \]
				<A href='?src=\ref[src];simplemake=monkey;mob=\ref[M]'>Monkey</A> |
				<A href='?src=\ref[src];simplemake=robot;mob=\ref[M]'>Cyborg</A> |
				<A href='?src=\ref[src];simplemake=cat;mob=\ref[M]'>Cat</A> |
				<A href='?src=\ref[src];simplemake=runtime;mob=\ref[M]'>Runtime</A> |
				<A href='?src=\ref[src];simplemake=corgi;mob=\ref[M]'>Corgi</A> |
				<A href='?src=\ref[src];simplemake=ian;mob=\ref[M]'>Ian</A> |
				<A href='?src=\ref[src];simplemake=crab;mob=\ref[M]'>Crab</A> |
				<A href='?src=\ref[src];simplemake=coffee;mob=\ref[M]'>Coffee</A> |
				\[ Construct: <A href='?src=\ref[src];simplemake=constructarmoured;mob=\ref[M]'>Armoured</A> ,
				<A href='?src=\ref[src];simplemake=constructbuilder;mob=\ref[M]'>Builder</A> ,
				<A href='?src=\ref[src];simplemake=constructwraith;mob=\ref[M]'>Wraith</A> \]
				<A href='?src=\ref[src];simplemake=shade;mob=\ref[M]'>Shade</A>
				<br>
			"}
	body += {"<br><br>
			<b>Other actions:</b>
			<br>
			<A href='?src=\ref[src];forcespeech=\ref[M]'>Forcesay</A>
			"}
	if (M.client)
		body += {" |
			<A href='?src=\ref[src];tdome1=\ref[M]'>Thunderdome 1</A> |
			<A href='?src=\ref[src];tdome2=\ref[M]'>Thunderdome 2</A> |
			<A href='?src=\ref[src];tdomeadmin=\ref[M]'>Thunderdome Admin</A> |
			<A href='?src=\ref[src];tdomeobserve=\ref[M]'>Thunderdome Observer</A> |
		"}
	// language toggles
	body += "<br><br><b>Languages:</b><br>"
	var/f = 1
	for(var/datum/prototype/language/L as anything in tim_sort(RSlanguages.fetch_subtypes_immutable(/datum/prototype/language), /proc/cmp_name_asc))
		if(!(L.language_flags & LANGUAGE_INNATE))
			if(!f) body += " | "
			else f = 0
			if(L in M.languages)
				body += "<a href='?src=\ref[src];toglang=\ref[M];lang=[html_encode(L.name)]' style='color:#006600'>[L.name]</a>"
			else
				body += "<a href='?src=\ref[src];toglang=\ref[M];lang=[html_encode(L.name)]' style='color:#ff0000'>[L.name]</a>"

	body += {"<br>
		</body></html>
	"}

	usr << browse(body, "window=[M.ckey]_playerpanel;size=550x515")
	feedback_add_details("admin_verb","SPP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

#define PLAYER_NOTES_ENTRIES_PER_PAGE 50
/datum/admins/proc/PlayerNotes()
	set category = "Admin"
	set name = "Player Notes"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	//PlayerNotesPage(1)
	tgui_notes()

/datum/admins/proc/tgui_notes()
	var/savefile/S=new("data/player_notes.sav")
	var/list/note_keys
	S >> note_keys
	var/selected_ckey = tgui_input_list(usr, "Select the ckey you want the notes off:", "Ckey Select",sortList(note_keys))
	show_player_info(selected_ckey)

/datum/admins/proc/PlayerNotesPage(page)
	var/dat = "<B>Player notes</B><HR>"
	var/savefile/S=new("data/player_notes.sav")
	var/list/note_keys
	S >> note_keys
	if(!note_keys)
		dat += "No notes found."
	else
		dat += "<table>"
		note_keys = sortList(note_keys)

		// Display the notes on the current page
		var/number_pages = note_keys.len / PLAYER_NOTES_ENTRIES_PER_PAGE
		// Emulate CEILING(why does BYOND not have ceil, 1)
		if(number_pages != round(number_pages))
			number_pages = round(number_pages) + 1
		var/page_index = page - 1
		if(page_index < 0 || page_index >= number_pages)
			return

		var/lower_bound = page_index * PLAYER_NOTES_ENTRIES_PER_PAGE + 1
		var/upper_bound = (page_index + 1) * PLAYER_NOTES_ENTRIES_PER_PAGE
		upper_bound = min(upper_bound, note_keys.len)
		for(var/index = lower_bound, index <= upper_bound, index++)
			var/t = note_keys[index]
			dat += "<tr><td><a href='?src=\ref[src];notes=show;ckey=[t]'>[t]</a></td></tr>"

		dat += "</table><br>"

		// Display a footer to select different pages
		for(var/index = 1, index <= number_pages, index++)
			if(index == page)
				dat += "<b>"
			dat += "<a href='?src=\ref[src];notes=list;index=[index]'>[index]</a> "
			if(index == page)
				dat += "</b>"

	usr << browse(HTML_SKELETON(dat), "window=player_notes;size=400x400")


/datum/admins/proc/player_has_info(var/key as text)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || !infos.len) return 0
	else return 1


/datum/admins/proc/show_player_info(var/key as text)
	set category = "Admin"
	set name = "Show Player Info"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	var/dat = "<html><head><title>Info on [key]</title></head>"
	dat += "<body>"

	var/p_age = "unknown"
	for(var/client/C in GLOB.clients)
		if(C.ckey == key)
			p_age = C.player.player_age
			break
	dat +="<span style='color:#000000; font-weight: bold'>Player age: [p_age]</span><br>"

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/update_file = 0
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
				update_file = 1
			if(!I.rank)
				I.rank = "N/A"
				update_file = 1
			dat += "<font color=#008800>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color=blue>[I.timestamp]</i></font> "
			if(I.author == usr.key || I.author == "Adminbot" || ishost(usr))
				dat += "<A href='?src=\ref[src];remove_player_info=[key];remove_index=[i]'>Remove</A>"
			dat += "<br><br>"
		if(update_file)
			info << infos

	dat += "<br>"
	dat += "<A href='?src=\ref[src];add_player_info=[key]'>Add Comment</A><br>"

	dat += "</body></html>"
	usr << browse(HTML_SKELETON(dat), "window=adminplayerinfo;size=480x480")



/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	var/dat
	dat = "<HEAD><TITLE>Admin Newscaster</TITLE></HEAD><H3>Admin Newscaster Unit</H3>"

	switch(admincaster_screen)
		if(0)
			dat += {"Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network.
				<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units.
				<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!
			"}
			if(news_network.wanted_issue)
				dat+= "<HR><A href='?src=\ref[src];ac_view_wanted=1'>Read Wanted Issue</A>"

			dat+= {"<HR><BR><A href='?src=\ref[src];ac_create_channel=1'>Create Feed Channel</A>
				<BR><A href='?src=\ref[src];ac_view=1'>View Feed Channels</A>
				<BR><A href='?src=\ref[src];ac_create_feed_story=1'>Submit new Feed story</A>
				<BR><BR><A href='?src=\ref[usr];mach_close=newscaster_main'>Exit</A>
			"}

			var/wanted_already = 0
			if(news_network.wanted_issue)
				wanted_already = 1

			dat+={"<HR><B>Feed Security functions:</B><BR>
				<BR><A href='?src=\ref[src];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] 'Wanted' Issue</A>
				<BR><A href='?src=\ref[src];ac_menu_censor_story=1'>Censor Feed Stories</A>
				<BR><A href='?src=\ref[src];ac_menu_censor_channel=1'>Mark Feed Channel with [(LEGACY_MAP_DATUM).company_name] D-Notice (disables and locks the channel.</A>
				<BR><HR><A href='?src=\ref[src];ac_set_signature=1'>The newscaster recognises you as:<BR> <FONT COLOR='green'>[src.admincaster_signature]</FONT></A>
			"}
		if(1)
			dat+= "Station Feed Channels<HR>"
			if( !length(news_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen'><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
					else
						dat+="<B><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR></B>"
			dat+={"<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>
			"}

		if(2)
			dat+={"
				Creating new Feed Channel...
				<HR><B><A href='?src=\ref[src];ac_set_channel_name=1'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>
				<B><A href='?src=\ref[src];ac_set_signature=1'>Channel Author</A>:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>
				<B><A href='?src=\ref[src];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>
				<BR><A href='?src=\ref[src];ac_submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(3)
			dat+={"
				Creating new Feed Message...
				<HR><B><A href='?src=\ref[src];ac_set_channel_receiving=1'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>
				<B>Message Author:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>
				<B><A href='?src=\ref[src];ac_set_new_message=1'>Message Body</A>:</B> [src.admincaster_feed_message.body] <BR>
				<BR><A href='?src=\ref[src];ac_submit_new_message=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>
			"}
		if(4)
			dat+={"
					Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>
					<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
				"}
		if(5)
			dat+={"
				Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(6)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid channel name.</FONT><BR>"
			var/check = 0
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+="<FONT COLOR='maroon'>Channel name already in use.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT>\]</FONT><HR>"
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a [(LEGACY_MAP_DATUM).company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( !length(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					var/i = 0
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						dat+="-[MESSAGE.body] <BR>"
						if(MESSAGE.img)
							usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
						dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
			dat+={"
				<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>
				<BR><A href='?src=\ref[src];ac_setScreen=[1]'>Back</A>
			"}
		if(10)
			dat+={"
				<B>[(LEGACY_MAP_DATUM).company_name] Feed Censorship Tool</B><BR>
				<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>
				Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>
				<HR>Select Feed channel to get Stories from:<BR>
			"}
			if(!length(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+={"
				<B>[(LEGACY_MAP_DATUM).company_name] D-Notice Handler</B><HR>
				<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's
				morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed
				stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>
			"}
			if(!length(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>
			"}
			if( !length(src.admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+={"
						-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>
						<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];ac_censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>
					"}
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+={"
				<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>
				Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];ac_toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>
			"}
			if(src.admincaster_feed_channel.censored)
				dat+={"
					<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a [(LEGACY_MAP_DATUM).company_name] D-Notice.<BR>
					No further feed story additions are allowed while the D-Notice is in effect.<BR><BR>
				"}
			else
				if( !length(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[11]'>Back</A>"
		if(14)
			dat+="<B>Wanted Issue Handler:</B>"
			var/wanted_already = 0
			var/end_param = 1
			if(news_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			if(wanted_already)
				dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"
			dat+={"
				<HR>
				<A href='?src=\ref[src];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_feed_message.author] <BR>
				<A href='?src=\ref[src];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_feed_message.body] <BR>
			"}
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'> [news_network.wanted_issue.backup_author]</FONT><BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'> [src.admincaster_signature]</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='?src=\ref[src];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+={"
				<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] is now in Network Circulation.</FONT><BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(16)
			dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_message.author =="" || src.admincaster_feed_message.author == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid name for person wanted.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid description.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+={"
				<B>Wanted Issue successfully deleted from Circulation</B><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		if(18)
			dat+={"
				<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>
				<B>Criminal</B>: [news_network.wanted_issue.author]<BR>
				<B>Description</B>: [news_network.wanted_issue.body]<BR>
				<B>Photo:</B>:
			"}
			if(news_network.wanted_issue.img)
				usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+={"
				<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] successfully edited.</FONT><BR><BR>
				<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>
			"}
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

	//to_chat(world, "Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]")
	//to_chat(world, "Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]")
	usr << browse(dat, "window=admincaster_main;size=400x600")
	onclose(usr, "admincaster_main")



/datum/admins/proc/Jobbans()
	if(!check_rights(R_BAN))	return

	var/dat = "<B>Job Bans!</B><HR><table>"
	for(var/t in jobban_keylist)
		var/r = t
		if( findtext(r,"##") )
			r = copytext( r, 1, findtext(r,"##") )//removes the description
		dat += "<tr><td>[t] (<A href='?src=\ref[src];removejobban=[r]'>unban</A>)</td></tr>"
	dat += "</table>"
	usr << browse(HTML_SKELETON(dat), "window=ban;size=400x400")

/datum/admins/proc/Game()
	if(!check_rights(0))	return

	var/dat = {"
		<center><B>Game Panel</B></center><hr>\n
		<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		"}
	if(master_mode == "secret")
		dat += "<A href='?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += {"
		<BR>
		<A href='?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>
		<br><A href='?src=\ref[src];atmos_vsc=1'>Modify Atmospherics Properties</A><br>
		"}

	usr << browse(HTML_SKELETON(dat), "window=admin2;size=210x280")
	return

/datum/admins/proc/Secrets(var/datum/admin_secret_category/active_category = null)
	if(!check_rights(0))	return

	// Print the header with category selection buttons.
	var/dat = "<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>"
	for(var/datum/admin_secret_category/category in admin_secrets.categories)
		if(!category.can_view(usr))
			continue
		dat += "<A href='?src=\ref[src];admin_secrets_panel=\ref[category]'>[category.name]</A> "
	dat += "<HR>"

	// If a category is selected, print its description and then options
	if(istype(active_category) && active_category.can_view(usr))
		dat += "<B>[active_category.name]</B><BR>"
		if(active_category.desc)
			dat += "<I>[active_category.desc]</I><BR>"
		for(var/datum/admin_secret_item/item in active_category.items)
			if(!item.can_view(usr))
				continue
			dat += "<A href='?src=\ref[src];admin_secrets=\ref[item]'>[item.name()]</A><BR>"
		dat += "<BR>"

	var/datum/browser/popup = new(usr, "secrets", "Secrets", 500, 500)
	popup.set_content(dat)
	popup.open()
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs



/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))	return

	var/message = input("Global message to send:", "Admin Announce", null, null)  as message//todo: sanitize for all?
	if(trim(message))
		if(!check_rights(R_SERVER,0))
			message = sanitize(message, 500, extra = 0)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		to_chat(world, "<span class=notice><b>[usr.client.is_under_stealthmin() ? "Administrator" : usr.key] Announces:</b><p style='text-indent: 50px'>[message]</p></span>")
		log_admin("Announce: [key_name(usr)] : [message]")
	feedback_add_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/// This verb for the purpose of making it compliant with the announcer system.
var/datum/legacy_announcement/priority/admin_pri_announcer = new
var/datum/legacy_announcement/minor/admin_min_announcer = new
/datum/admins/proc/intercom()
	set category = "Fun"
	set name = "Intercom Msg"
	set desc = "Send an intercom message, like an arrivals announcement."
	if(!check_rights(0))	return

	var/channel = input("Channel for message:","Channel", null) as null|anything in radiochannels

	if(channel) //They picked a channel
		var/sender = input("Name of sender (max 75):", "Announcement", "Announcement Computer") as null|text

		if(sender) //They put a sender
			sender = sanitize(sender, 75, extra = 0)
			var/message = input("Message content (max 500):", "Contents", "This is a test of the announcement system.") as null|message

			if(message) //They put a message
				message = sanitize(message, 500, extra = 0)
				GLOB.global_announcer.autosay("[message]", "[sender]", "[channel == "Common" ? null : channel]") //Common is a weird case, as it's not a "channel", it's just talking into a radio without a channel set.
				log_admin("Intercom: [key_name(usr)] : [sender]:[message]")

	feedback_add_details("admin_verb","IN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/intercom_convo()
	set category = "Fun"
	set name = "Intercom Convo"
	set desc = "Send an intercom conversation, like several uses of the Intercom Msg verb."
	set waitfor = FALSE //Why bother? We have some sleeps. You can leave tho!
	if(!check_rights(0))	return

	var/channel = input("Channel for message:","Channel", null) as null|anything in radiochannels

	if(!channel) //They picked a channel
		return

	to_chat(usr,"<span class='notice'><B>Intercom Convo Directions</B><br>Start the conversation with the sender, a pipe (|), and then the message on one line. Then hit enter to \
		add another line, and type a (whole) number of seconds to pause between that message, and the next message, then repeat the message syntax up to 20 times. For example:<br>\
		--- --- ---<br>\
		Some Guy|Hello guys, what's up?<br>\
		5<br>\
		Other Guy|Hey, good to see you.<br>\
		5<br>\
		Some Guy|Yeah, you too.<br>\
		--- --- ---<br>\
		The above will result in those messages playing, with a 5 second gap between each. Maximum of 20 messages allowed.</span>")

	var/list/decomposed
	var/message = input(usr,"See your chat box for instructions. Keep a copy elsewhere in case it is rejected when you click OK.", "Input Conversation", "") as null|message

	if(!message)
		return

	//Split on pipe or \n
	decomposed = splittext(message,regex("\\||$","m"))
	decomposed += "0" //Tack on a final 0 sleep to make 3-per-message evenly

	//Time to find how they screwed up.
	//Wasn't the right length
	if((length(decomposed)+1) % 3) //+1 to accomidate the lack of a wait time for the last message
		to_chat(usr,"<span class='warning'>You passed [decomposed.len] segments (senders+messages+pauses). You must pass a multiple of 3, minus 1 (no pause after the last message). That means a sender and message on every other line (starting on the first), separated by a pipe character (|), and a number every other line that is a pause in seconds.</span>")
		return

	//Too long a conversation
	if((decomposed.len / 3) > 20)
		to_chat(usr,"<span class='warning'>This conversation is too long! 20 messages maximum, please.</span>")
		return

	//Missed some sleeps, or sanitized to nothing.
	for(var/i = 1; i < decomposed.len; i++)

		//Sanitize sender
		var/clean_sender = sanitize(decomposed[i])
		if(!clean_sender)
			to_chat(usr,"<span class='warning'>One part of your conversation was not able to be sanitized. It was the sender of the [(i+2)/3]\th message.</span>")
			return
		decomposed[i] = clean_sender

		//Sanitize message
		var/clean_message = sanitize(decomposed[++i])
		if(!clean_message)
			to_chat(usr,"<span class='warning'>One part of your conversation was not able to be sanitized. It was the body of the [(i+2)/3]\th message.</span>")
			return
		decomposed[i] = clean_message

		//Sanitize wait time
		var/clean_time = text2num(decomposed[++i])
		if(!isnum(clean_time))
			to_chat(usr,"<span class='warning'>One part of your conversation was not able to be sanitized. It was the wait time after the [(i+2)/3]\th message.</span>")
			return
		if(clean_time > 60)
			to_chat(usr,"<span class='warning'>Max 60 second wait time between messages for sanity's sake please.</span>")
			return
		decomposed[i] = clean_time

	log_admin("Intercom convo started by: [key_name(usr)] : [sanitize(message)]")
	feedback_add_details("admin_verb","IN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	//Sanitized AND we still have a chance to send it? Wow!
	if(LAZYLEN(decomposed))
		for(var/i = 1; i < decomposed.len; i++)
			var/this_sender = decomposed[i]
			var/this_message = decomposed[++i]
			var/this_wait = decomposed[++i]
			GLOB.global_announcer.autosay("[this_message]", "[this_sender]", "[channel == "Common" ? null : channel]") //Common is a weird case, as it's not a "channel", it's just talking into a radio without a channel set.
			sleep(this_wait SECONDS)

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"

	if(!check_rights(R_ADMIN))
		return

	config_legacy.ooc_allowed = !(config_legacy.ooc_allowed)
	to_chat(world, "<span class='oocplain'><B>The OOC channel has been globally [config_legacy.ooc_allowed ? "enabled" : "disabled"].</B></span>")
	log_and_message_admins("toggled OOC.")
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc="Globally Toggles LOOC"
	set name="Toggle LOOC"

	if(!check_rights(R_ADMIN))
		return

	config_legacy.looc_allowed = !(config_legacy.looc_allowed)
	to_chat(world, "<span class='oocplain'><B>The LOOC channel has been globally [config_legacy.looc_allowed ? "enabled" : "disabled"].</B></span>")
	log_and_message_admins("toggled LOOC.")
	feedback_add_details("admin_verb","TLOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggledsay()
	set category = "Server"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"

	if(!check_rights(R_ADMIN))
		return

	config_legacy.dsay_allowed = !(config_legacy.dsay_allowed)
	to_chat(world, "<span class='oocplain'><B>Deadchat has been globally [config_legacy.dsay_allowed ? "enabled" : "disabled"].</B></span>")
	log_admin("[key_name(usr)] toggled deadchat.")
	message_admins("[key_name_admin(usr)] toggled deadchat.", 1)
	feedback_add_details("admin_verb","TDSAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle Dead OOC."
	set name="Toggle Dead OOC"

	if(!check_rights(R_ADMIN))
		return

	config_legacy.dooc_allowed = !( config_legacy.dooc_allowed )
	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)
	feedback_add_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglehubvisibility()
	set category = "Server"
	set desc="Globally Toggles Hub Visibility"
	set name="Toggle Hub Visibility"

	if(!check_rights(R_ADMIN))
		return

	world.update_hub_visibility(!GLOB.hub_visibility)
	log_admin("[key_name(usr)] toggled hub visibility.")
	message_admins("[key_name_admin(usr)] toggled hub visibility.  The server is now [GLOB.hub_visibility ? "visible" : "invisible"] ([GLOB.hub_visibility]).", 1)
	feedback_add_details("admin_verb","THUB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc

/datum/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	config_legacy.traitor_scaling = !config_legacy.traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [config_legacy.traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [config_legacy.traitor_scaling ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		SSticker.start_immediately = TRUE
		log_admin("[usr.key] has started the game.")
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_INIT)
			msg = " (The server is still setting up, but the round will be started as soon as possible.)"
		message_admins(SPAN_ADMINNOTICE("[usr.key] has started the game.[msg]"))
		feedback_add_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		to_chat(usr, SPAN_WARNING("Error: Start Now: Game has already started."))
		return 0

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	config_legacy.enter_allowed = !(config_legacy.enter_allowed)
	if (!(config_legacy.enter_allowed))
		to_chat(world, "<B>New players may no longer enter the game.</B>")
	else
		to_chat(world, "<B>New players may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("<font color=#4F49AF>[key_name_admin(usr)] toggled new player game entering.</font>", 1)
	world.update_status()
	feedback_add_details("admin_verb","TE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	config_legacy.allow_ai = !( config_legacy.allow_ai )
	if (!( config_legacy.allow_ai ))
		to_chat(world, "<B>The AI job is no longer chooseable.</B>")
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>")
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	feedback_add_details("admin_verb","TAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc = "Respawn basically"
	set name = "Toggle Respawn"
	config_legacy.abandon_allowed = !(config_legacy.abandon_allowed)
	if(config_legacy.abandon_allowed)
		to_chat(world, "<B>Returning to menu as a ghost is now allowed.</B>")
	else
		to_chat(world, "<B>Returning to menu as a ghost is no longer allowed :(</B>")
	message_admins("<font color=#4F49AF>[key_name_admin(usr)] toggled respawn to [config_legacy.abandon_allowed ? "On" : "Off"].</font>", 1)
	log_admin("[key_name(usr)] toggled respawn to [config_legacy.abandon_allowed ? "On" : "Off"].")
	world.update_status()
	feedback_add_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_aliens()
	set category = "Server"
	set desc="Toggle alien mobs"
	set name="Toggle Aliens"
	config_legacy.aliens_allowed = !config_legacy.aliens_allowed
	log_admin("[key_name(usr)] toggled Aliens to [config_legacy.aliens_allowed].")
	message_admins("[key_name_admin(usr)] toggled Aliens [config_legacy.aliens_allowed ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_space_ninja()
	set category = "Server"
	set desc="Toggle space ninjas spawning."
	set name="Toggle Space Ninjas"
	config_legacy.ninjas_allowed = !config_legacy.ninjas_allowed
	log_admin("[key_name(usr)] toggled Space Ninjas to [config_legacy.ninjas_allowed].")
	message_admins("[key_name_admin(usr)] toggled Space Ninjas [config_legacy.ninjas_allowed ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TSN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay_end()
	set category = "Server"
	set desc = "Prevent the server from restarting"
	set name = "Delay Reboot"

	if(!check_rights(R_SERVER))
		return

	if(SSticker.delay_end)
		tgui_alert(usr, "The round end is already delayed. The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Alert", list("Ok"))
		return

	var/delay_reason = input(usr, "Enter a reason for delaying the round end", "Round Delay Reason") as null|text

	if(isnull(delay_reason))
		return

	if(SSticker.delay_end)
		tgui_alert(usr, "The round end is already delayed. The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Alert", list("Ok"))
		return

	SSticker.delay_end = TRUE
	SSticker.admin_delay_notice = delay_reason

	log_admin("[key_name(usr)] delayed the round end for reason: [SSticker.admin_delay_notice]")
	message_admins("[key_name_admin(usr)] delayed the round end for reason: [SSticker.admin_delay_notice]")
	// SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Delay Round End", "Reason: [delay_reason]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay_start()
	set category = "Server"
	set desc = "Delay the game start"
	set name = "Delay pre-game"

	var/newtime = input("Set a new time in seconds. Set -1 for indefinite delay.","Set Delay",round(SSticker.GetTimeLeft()/10)) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!")
	if(newtime)
		newtime = newtime*10
		SSticker.SetTimeLeft(newtime)
		if(newtime < 0)
			to_chat(world, "<b>The game start has been delayed.</b>")
			log_admin("[key_name(usr)] delayed the round start.")
		else
			to_chat(world, "<b>The game will start in [DisplayTimeText(newtime)].</b>")
			SEND_SOUND(world, sound('sound/announcer/classic/attention.ogg'))
			log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")
//		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay Game Start") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config_legacy.allow_admin_jump = !(config_legacy.allow_admin_jump)
	message_admins("<font color=#4F49AF>Toggled admin jumping to [config_legacy.allow_admin_jump].</font>")
	feedback_add_details("admin_verb","TJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config_legacy.allow_admin_spawning = !(config_legacy.allow_admin_spawning)
	message_admins("<font color=#4F49AF>Toggled admin item spawning to [config_legacy.allow_admin_spawning].</font>")
	feedback_add_details("admin_verb","TAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/unprison(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (M.z == 2)
		if (config_legacy.allow_admin_jump)
			M.forceMove(SSjob.get_latejoin_spawnpoint(faction = JOB_FACTION_STATION))
			message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]", 1)
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			alert("Admin jumping disabled")
	else
		alert("[M.name] is not prisoned.")
	feedback_add_details("admin_verb","UP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(var/character) // returns 1 for special characters and 2 for heroes of gamemode
	if(!SSticker || !SSticker.mode)
		return 0
	var/datum/mind/M
	if (ismob(character))
		var/mob/C = character
		M = C.mind
	else if(istype(character, /datum/mind))
		M = character

	if(M)
		if(SSticker.mode.antag_templates && SSticker.mode.antag_templates.len)
			for(var/datum/antagonist/antag in SSticker.mode.antag_templates)
				if(antag.is_antagonist(M))
					return 2
		if(M.special_role)
			return 1

	if(isrobot(character))
		var/mob/living/silicon/robot/R = character
		if(R.emagged)
			return 1

	return 0

/datum/admins/proc/spawn_fruit(seedtype in SSplants.seeds)
	set category = "Debug"
	set desc = "Spawn the product of a seed."
	set name = "Spawn Fruit"

	if(!check_rights(R_SPAWN))	return

	if(!seedtype || !SSplants.seeds[seedtype])
		return
	var/datum/seed/S = SSplants.seeds[seedtype]
	S.harvest(usr,0,0,1)
	log_admin("[key_name(usr)] spawned [seedtype] fruit at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/spawn_custom_item()
	set category = "Debug"
	set desc = "Spawn a custom item."
	set name = "Spawn Custom Item"

	if(!check_rights(R_SPAWN))	return

	var/owner = input("Select a ckey.", "Spawn Custom Item") as null|anything in custom_items
	if(!owner|| !custom_items[owner])
		return

	var/list/possible_items = custom_items[owner]
	var/datum/custom_item/item_to_spawn = input("Select an item to spawn.", "Spawn Custom Item") as null|anything in possible_items
	if(!item_to_spawn)
		return

	item_to_spawn.spawn_item(get_turf(usr))

/datum/admins/proc/check_custom_items()

	set category = "Debug"
	set desc = "Check the custom item list."
	set name = "Check Custom Items"

	if(!check_rights(R_SPAWN))	return

	if(!custom_items)
		to_chat(usr, "Custom item list is null.")
		return

	if(!custom_items.len)
		to_chat(usr, "Custom item list not populated.")
		return

	for(var/assoc_key in custom_items)
		to_chat(usr, "[assoc_key] has:")
		var/list/current_items = custom_items[assoc_key]
		for(var/datum/custom_item/item in current_items)
			to_chat(usr, "- name: [item.name] icon: [item.item_icon] path: [item.item_path] desc: [item.item_desc]")

/datum/admins/proc/spawn_plant(seedtype in SSplants.seeds)
	set category = "Debug"
	set desc = "Spawn a spreading plant effect."
	set name = "Spawn Plant"

	if(!check_rights(R_SPAWN))	return

	if(!seedtype || !SSplants.seeds[seedtype])
		return
	new /obj/effect/plant(get_turf(usr), SSplants.seeds[seedtype])
	log_admin("[key_name(usr)] spawned [seedtype] vines at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/show_traitor_panel(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()
	feedback_add_details("admin_verb","STP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/show_game_mode()
	set category = "Admin"
	set desc = "Show the current round configuration."
	set name = "Show Game Mode"

	if(!SSticker || !SSticker.mode)
		alert("Not before roundstart!", "Alert")
		return

	var/out = "<font size=3><b>Current mode: [SSticker.mode.name] (<a href='?src=\ref[SSticker.mode];debug_antag=self'>[SSticker.mode.config_tag]</a>)</b></font><br/>"
	out += "<hr>"

	if(SSticker.mode.ert_disabled)
		out += "<b>Emergency Response Teams:</b> <a href='?src=\ref[SSticker.mode];toggle=ert'>disabled</a>"
	else
		out += "<b>Emergency Response Teams:</b> <a href='?src=\ref[SSticker.mode];toggle=ert'>enabled</a>"
	out += "<br/>"

	if(SSticker.mode.deny_respawn)
		out += "<b>Respawning:</b> <a href='?src=\ref[SSticker.mode];toggle=respawn'>disallowed</a>"
	else
		out += "<b>Respawning:</b> <a href='?src=\ref[SSticker.mode];toggle=respawn'>allowed</a>"
	out += "<br/>"

	out += "<b>Shuttle delay multiplier:</b> <a href='?src=\ref[SSticker.mode];set=shuttle_delay'>[SSticker.mode.shuttle_delay]</a><br/>"

	if(SSticker.mode.auto_recall_shuttle)
		out += "<b>Shuttle auto-recall:</b> <a href='?src=\ref[SSticker.mode];toggle=shuttle_recall'>enabled</a>"
	else
		out += "<b>Shuttle auto-recall:</b> <a href='?src=\ref[SSticker.mode];toggle=shuttle_recall'>disabled</a>"
	out += "<br/><br/>"

	if(SSticker.mode.event_delay_mod_moderate)
		out += "<b>Moderate event time modifier:</b> <a href='?src=\ref[SSticker.mode];set=event_modifier_moderate'>[SSticker.mode.event_delay_mod_moderate]</a><br/>"
	else
		out += "<b>Moderate event time modifier:</b> <a href='?src=\ref[SSticker.mode];set=event_modifier_moderate'>unset</a><br/>"

	if(SSticker.mode.event_delay_mod_major)
		out += "<b>Major event time modifier:</b> <a href='?src=\ref[SSticker.mode];set=event_modifier_severe'>[SSticker.mode.event_delay_mod_major]</a><br/>"
	else
		out += "<b>Major event time modifier:</b> <a href='?src=\ref[SSticker.mode];set=event_modifier_severe'>unset</a><br/>"

	out += "<hr>"

	if(SSticker.mode.antag_tags && SSticker.mode.antag_tags.len)
		out += "<b>Core antag templates:</b></br>"
		for(var/antag_tag in SSticker.mode.antag_tags)
			out += "<a href='?src=\ref[SSticker.mode];debug_antag=[antag_tag]'>[antag_tag]</a>.</br>"

	if(SSticker.mode.round_autoantag)
		out += "<b>Autotraitor <a href='?src=\ref[SSticker.mode];toggle=autotraitor'>enabled</a></b>."
		if(SSticker.mode.antag_scaling_coeff > 0)
			out += " (scaling with <a href='?src=\ref[SSticker.mode];set=antag_scaling'>[SSticker.mode.antag_scaling_coeff]</a>)"
		else
			out += " (not currently scaling, <a href='?src=\ref[SSticker.mode];set=antag_scaling'>set a coefficient</a>)"
		out += "<br/>"
	else
		out += "<b>Autotraitor <a href='?src=\ref[SSticker.mode];toggle=autotraitor'>disabled</a></b>.<br/>"

	out += "<b>All antag ids:</b>"
	if(SSticker.mode.antag_templates && SSticker.mode.antag_templates.len)
		for(var/datum/antagonist/antag in SSticker.mode.antag_templates)
			antag.update_current_antag_max()
			out += " <a href='?src=\ref[SSticker.mode];debug_antag=[antag.id]'>[antag.id]</a>"
			out += " ([antag.get_antag_count()]/[antag.cur_max]) "
			out += " <a href='?src=\ref[SSticker.mode];remove_antag_type=[antag.id]'>\[-\]</a><br/>"
	else
		out += " None."
	out += " <a href='?src=\ref[SSticker.mode];add_antag_type=1'>\[+\]</a><br/>"

	usr << browse(out, "window=edit_mode[src]")
	feedback_add_details("admin_verb","SGM")


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmets."
	config_legacy.welder_vision = !( config_legacy.welder_vision )
	if (config_legacy.welder_vision)
		to_chat(world, "<B>Reduced welder vision has been enabled!</B>")
	else
		to_chat(world, "<B>Reduced welder vision has been disabled!</B>")
	log_admin("[key_name(usr)] toggled welder vision.")
	message_admins("[key_name_admin(usr)] toggled welder vision.", 1)
	feedback_add_details("admin_verb","TTWH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	config_legacy.guests_allowed = !(config_legacy.guests_allowed)
	if (!(config_legacy.guests_allowed))
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [config_legacy.guests_allowed?"":"dis"]allowed.")
	message_admins("<font color=#4F49AF>[key_name_admin(usr)] toggled guests game entering [config_legacy.guests_allowed?"":"dis"]allowed.</font>", 1)
	feedback_add_details("admin_verb","TGU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in GLOB.mob_list)
		ai_number++
		if(isAI(S))
			to_chat(usr, "<b>AI [key_name(S, usr)]'s laws:</b>")
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			to_chat(usr, "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independent)"]: laws:</b>")
		else if (ispAI(S))
			to_chat(usr, "<b>pAI [key_name(S, usr)]'s laws:</b>")
		else
			to_chat(usr, "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>")

		if (S.laws == null)
			to_chat(usr, "[key_name(S, usr)]'s laws are null?? Contact a coder.")
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		to_chat(usr, "<b>No AIs located</b>") //Just so you know the thing is actually working and not just ignoring you.

/*
/datum/admins/proc/show_skills()
	set category = "Admin"
	set name = "Show Skills"

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/mob/living/carbon/human/M = input("Select mob.", "Select mob.") as null|anything in human_mob_list
	if(!M) return

	show_skill_window(usr, M)

	return
*/
/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(istype(H))
		H.regenerate_icons()

/proc/get_options_bar(whom, detail = 2, name = 0, link = 1, highlight_special = 1)
	if(!whom)
		return "<b>(*null*)</b>"
	var/mob/M
	var/client/C
	if(istype(whom, /client))
		C = whom
		M = C.mob
	else if(istype(whom, /mob))
		M = whom
		C = M.client
	else
		return "<b>(*not a mob*)</b>"
	switch(detail)
		if(0)
			return "<b>[key_name(C, link, name, highlight_special)]</b>"

		if(1)	//Private Messages
			return "<b>[key_name(C, link, name, highlight_special)](<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)</b>"

		if(2)	//Admins
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special)](<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) ([admin_jump_link(M)]) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>) (<A HREF='?_src_=holder;take_question=\ref[M]'>TAKE</A>)</b>"

		if(3)	//Devs
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special)](<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>)([admin_jump_link(M)]) (<A HREF='?_src_=holder;take_question=\ref[M]'>TAKE</A>)</b>"

		if(4)	//Event Managers
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) ([admin_jump_link(M)]) (<A HREF='?_src_=holder;take_question=\ref[M]'>TAKE</A>)</b>"


/proc/ishost(whom)
	if(!whom)
		return 0
	var/client/C
	var/mob/M
	if(istype(whom, /client))
		C = whom
	if(istype(whom, /mob))
		M = whom
		C = M.client
	if(R_HOST & C.holder.rights)
		return 1
	else
		return 0
//
//
//ALL DONE
//*********************************************************************************************************
//

//Returns 1 to let the dragdrop code know we are trapping this event
//Returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(var/mob/observer/dead/frommob, var/mob/living/tomob)
	if(!istype(frommob))
		return //Extra sanity check to make sure only observers are shoved into things

	//Same as assume-direct-control perm requirements.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_ADMIN|R_DEBUG,0))
		return 0
	if (!frommob.ckey)
		return 0
	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"
	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return 1
	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1
	if(tomob.client) //No need to ghostize if there is no client
		tomob.ghostize(0)
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name].</span>")
	log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
	feedback_add_details("admin_verb","CGD")
	frommob.transfer_client_to(tomob)
	qdel(frommob)
	return 1

/datum/admins/proc/force_antag_latespawn()
	set category = "Admin"
	set name = "Force Template Spawn"
	set desc = "Force an antagonist template to spawn."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!SSticker || !SSticker.mode)
		to_chat(usr, "Mode has not started.")
		return

	var/antag_type = input("Choose a template.","Force Latespawn") as null|anything in GLOB.all_antag_types
	if(!antag_type || !GLOB.all_antag_types[antag_type])
		to_chat(usr, "Aborting.")
		return

	var/datum/antagonist/antag = GLOB.all_antag_types[antag_type]
	message_admins("[key_name(usr)] attempting to force latespawn with template [antag.id].")
	antag.attempt_late_spawn()

/datum/admins/proc/force_mode_latespawn()
	set category = "Admin"
	set name = "Force Mode Spawn"
	set desc = "Force autotraitor to proc."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins) || !check_rights(R_ADMIN))
		to_chat(usr, "Error: you are not an admin!")
		return

	if(!SSticker || !SSticker.mode)
		to_chat(usr, "Mode has not started.")
		return

	log_and_message_admins("attempting to force mode autospawn.")
	SSticker.mode.try_latespawn()

/datum/admins/proc/paralyze_mob(mob/living/H as mob)
	set category = "Admin"
	set name = "Toggle Paralyze"
	set desc = "Paralyzes a player. Or unparalyses them."

	var/msg

	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(!HAS_TRAIT(H, TRAIT_MOB_UNCONSCIOUS))
		ADD_TRAIT(H, TRAIT_MOB_UNCONSCIOUS, ADMIN_TRAIT)
		H.update_stat()
		msg = "has paralyzed [key_name(H)]."
		log_and_message_admins(msg)
	else
		if(alert(src, "[key_name(H)] is paralyzed, would you like to unparalyze them?",,"Yes","No") !="Yes")
			return
		REMOVE_TRAIT(H, TRAIT_MOB_UNCONSCIOUS, ADMIN_TRAIT)
		H.update_stat()
		msg = "has unparalyzed [key_name(H)]."
		log_and_message_admins(msg)

/datum/admins/proc/set_tcrystals(mob/living/carbon/human/H as mob)
	set category = "Debug"
	set name = "Set Telecrystals"
	set desc = "Allows admins to change telecrystals of a user."
	set popup_menu = FALSE
	var/crystals

	if(check_rights(R_ADMIN))
		crystals = input("Amount of telecrystals for [H.ckey], currently [H.mind.tcrystals].", crystals) as null|num
		if (!isnull(crystals))
			H.mind.tcrystals = crystals
			var/msg = "[key_name(usr)] has modified [H.ckey]'s telecrystals to [crystals]."
			message_admins(msg)
	else
		to_chat(usr, "You do not have access to this command.")

/datum/admins/proc/add_tcrystals(mob/living/carbon/human/H as mob)
	set category = "Debug"
	set name = "Add Telecrystals"
	set desc = "Allows admins to change telecrystals of a user by addition."
	set popup_menu = FALSE
	var/crystals

	if(check_rights(R_ADMIN))
		crystals = input("Amount of telecrystals to give to [H.ckey], currently [H.mind.tcrystals].", crystals) as null|num
		if (!isnull(crystals))
			H.mind.tcrystals += crystals
			var/msg = "[key_name(usr)] has added [crystals] to [H.ckey]'s telecrystals."
			message_admins(msg)
	else
		to_chat(usr, "You do not have access to this command.")


/datum/admins/proc/sendFax()
	set category = "Special Verbs"
	set name = "Send Fax"
	set desc = "Sends a fax to this machine"
	var/department = input("Choose a fax", "Fax") as null|anything in alldepartments
	for(var/obj/machinery/photocopier/faxmachine/sendto in allfaxes)
		if(sendto.department == department)

			if (!istype(src,/datum/admins))
				src = usr.client.holder
			if (!istype(src,/datum/admins))
				to_chat(usr, "Error: you are not an admin!")
				return

			var/replyorigin = input(src.owner, "Please specify who the fax is coming from", "Origin") as text|null

			var/obj/item/paper/admin/P = new /obj/item/paper/admin( null ) //hopefully the null loc won't cause trouble for us
			faxreply = P

			P.admindatum = src
			P.origin = replyorigin
			P.destination = sendto

			P.adminbrowse()


datum/admins/var/obj/item/paper/admin/faxreply // var to hold fax replies in

/datum/admins/proc/faxCallback(var/obj/item/paper/admin/P, var/obj/machinery/photocopier/faxmachine/destination)
	var/customname = input(src.owner, "Pick a title for the report", "Title") as text|null

	P.name = "[P.origin] - [customname]"
	P.desc = "This is a paper titled '" + P.name + "'."

	var/shouldStamp = 1
	if(!P.sender) // admin initiated
		switch(alert("Would you like the fax stamped?",, "Yes", "No"))
			if("No")
				shouldStamp = 0

	if(shouldStamp)
		P.stamps += "<hr><i>This paper has been stamped by the [P.origin] Quantum Relay.</i>"

		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		var/x
		var/y
		x = rand(-2, 0)
		y = rand(-1, 2)
		P.offset_x += x
		P.offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y

		if(!P.ico)
			P.ico = new
		P.ico += "paper_stamp-cent"
		stampoverlay.icon_state = "paper_stamp-cent"

		if(!P.stamped)
			P.stamped = new
		P.stamped += /obj/item/stamp/centcom
		P.add_overlay(stampoverlay)

	var/obj/item/rcvdcopy
	rcvdcopy = destination.copy(P)
	rcvdcopy.loc = null //hopefully this shouldn't cause trouble
	adminfaxes += rcvdcopy



	if(destination.receivefax(P))
		to_chat(src.owner, "<span class='notice'>Message reply to transmitted successfully.</span>")
		if(P.sender) // sent as a reply
			log_admin("[key_name(src.owner)] replied to a fax message from [key_name(P.sender)]")
			for(var/client/C in GLOB.admins)
				if((R_ADMIN | R_MOD) & C.holder.rights)
					to_chat(C, "<span class='admin'><span class='prefix'>FAX LOG:</span>[key_name_admin(src.owner)] replied to a fax message from [key_name_admin(P.sender)] (<a href='?_src_=holder;AdminFaxView=\ref[rcvdcopy]'>VIEW</a>)</span>")
		else
			log_admin("[key_name(src.owner)] has sent a fax message to [destination.department]")
			for(var/client/C in GLOB.admins)
				if((R_ADMIN | R_MOD) & C.holder.rights)
					to_chat(C, "<span class='admin'><span class='prefix'>FAX LOG:</span>[key_name_admin(src.owner)] has sent a fax message to [destination.department] (<a href='?_src_=holder;AdminFaxView=\ref[rcvdcopy]'>VIEW</a>)</span>")

	else
		to_chat(src.owner, "<span class='warning'>Message reply failed.</span>")

	spawn(100)
		qdel(P)
		faxreply = null
	return

/datum/admins/proc/update_stealth_ghost()
	if(!isobserver(owner.mob))
		return
	var/mob/observer/dead/dead = owner.mob
	var/stealthghost = owner.get_preference_toggle(/datum/game_preference_toggle/admin/stealth_hides_ghost)
	if(!stealthghost || !fakekey)
		dead.invisibility = initial(dead.invisibility)
		dead.alpha = initial(dead.alpha)
		if(dead.original_name)
			dead.name = dead.original_name
	else
		dead.invisibility = INVISIBILITY_MAXIMUM
		dead.alpha = 0
		dead.original_name = dead.name
		dead.name = "ghost"
