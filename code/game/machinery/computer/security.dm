//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/secure_data//TODO:SANITY
	name = "security records console"
	desc = "Used to view and edit personnel's security records"
	icon_state = "security"
	req_one_access = list(access_security, access_forensics_lockers)
	circuit = /obj/item/weapon/circuitboard/secure_data
	//var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending
	var/list/crimes = list()
	New()
		// Populate the crime list:
		for(var/x in typesof(/datum/crime))
			var/datum/crime/F = new x(src)
			if(!F.name)
				del(F)
				continue
			else
				crimes.Add(F)


/obj/machinery/computer/secure_data/attackby(obj/item/O as obj, user as mob)
	if(istype(O, /obj/item/weapon/card/id))
		if(!authenticated)
			var/obj/item/weapon/card/id/R = O
			active1 = null
			active2 = null
			if(check_access(R))
				authenticated = R.registered_name
				rank = R.assignment
				screen = 1
				updateUsrDialog()
	else
		..()

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/secure_data/attack_hand(mob/user as mob)
	if(..())
		return
	if (src.z > 6)
		user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
		return
	var/dat

	if (temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];choice=Clear Screen'>Clear Screen</A>", temp, src)
	else
		dat = ""
		if (authenticated)
			switch(screen)
				if(1.0)
					dat += text("<A href='?src=\ref[];choice=Log Out'>{Log Out}</A><br>",src)
					dat += {"
<p style='text-align:center;'>"}
					dat += text("<A href='?src=\ref[];choice=Search Records'>Search Records</A><BR>", src)
					dat += text("<A href='?src=\ref[];choice=New Record (General)'>New Record</A><BR>", src)
					dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
<th>Criminal Status</th>
</tr>"}
					if(!isnull(data_core.general))
						for(var/datum/data/record/R in sortRecord(data_core.general, sortBy, order))
							var/crimstat = ""
							for(var/datum/data/record/E in data_core.security)
								if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
									crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*Arrest*")
									background = "'background-color:#990000;'"
								if("Incarcerated")
									background = "'background-color:#CD6500;'"
								if("Parolled")
									background = "'background-color:#CD6500;'"
								if("Released")
									background = "'background-color:#006699;'"
								if("None")
									background = "'background-color:#4F7529;'"
								if("")
									background = "''" //"'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
							dat += text("<td>[]</td></tr>", crimstat)
						dat += "</table><hr width='75%' />"
					dat += text("<A href='?src=\ref[];choice=Record Maintenance'>Record Maintenance</A><br><br>", src)
				if(2.0)
					dat += "<B>Records Maintenance</B><HR>"
					dat += "<BR><A href='?src=\ref[src];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='?src=\ref[src];choice=Return'>Back</A>"
				if(3.0)
					dat += text("<A href='?src=\ref[];choice=Return'>Back</A>", src)
					dat += "<CENTER><B>Security Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						dat += text("Name: <A href='?src=\ref[];choice=Edit Field;field=name'>[]</A> ID: <A href='?src=\ref[];choice=Edit Field;field=id'>[]</A><BR>\nSex: <A href='?src=\ref[];choice=Edit Field;field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];choice=Edit Field;field=age'>[]</A><BR>\nRank: <A href='?src=\ref[];choice=Edit Field;field=rank'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];choice=Edit Field;field=fingerprint'>[]</A><BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src, active1.fields["name"], src, active1.fields["id"], src, active1.fields["sex"], src, active1.fields["age"], src, active1.fields["rank"], src, active1.fields["fingerprint"], active1.fields["p_stat"], active1.fields["m_stat"])
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						dat += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: <A href='?src=\ref[];choice=Edit Field;field=criminal'>[]</A>",src, active2.fields["criminal"])
						dat += text("<BR>\n<BR>\nMinor Crimes: <A href='?src=\ref[];choice=Edit Field;field=min_crim_add'>Add New</A>", src)


						dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
<th>Del</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["min_crim"])
							dat += "<tr><td>[c.crimeName]</td>"
							dat += "<td>[c.crimeDetails]</td>"
							dat += "<td>[c.author]</td>"
							dat += "<td>[c.time]</td>"
							dat += "<td><A href='?src=\ref[src];choice=Edit Field;field=min_crim_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"

						dat += text("<BR>\n<BR>\nMedium Crimes: <A href='?src=\ref[];choice=Edit Field;field=med_crim_add'>Add New</A>", src)


						dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
<th>Del</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["med_crim"])
							dat += "<tr><td>[c.crimeName]</td>"
							dat += "<td>[c.crimeDetails]</td>"
							dat += "<td>[c.author]</td>"
							dat += "<td>[c.time]</td>"
							dat += "<td><A href='?src=\ref[src];choice=Edit Field;field=med_crim_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"

						dat += text("<BR>\n<BR>\nMajor Crimes: <A href='?src=\ref[];choice=Edit Field;field=maj_crim_add'>Add New</A>", src)

						dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
<th>Del</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["maj_crim"])
							dat += "<tr><td>[c.crimeName]</td>"
							dat += "<td>[c.crimeDetails]</td>"
							dat += "<td>[c.author]</td>"
							dat += "<td>[c.time]</td>"
							dat += "<td><A href='?src=\ref[src];choice=Edit Field;field=maj_crim_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"

						dat += text("<BR>\n<BR>\nCapital Crimes: <A href='?src=\ref[];choice=Edit Field;field=cap_crim_add'>Add New</A>", src)

						dat +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
<th>Del</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["cap_crim"])
							dat += "<tr><td>[c.crimeName]</td>"
							dat += "<td>[c.crimeDetails]</td>"
							dat += "<td>[c.author]</td>"
							dat += "<td>[c.time]</td>"
							dat += "<td><A href='?src=\ref[src];choice=Edit Field;field=cap_crim_delete;cdataid=[c.dataId]'>\[X\]</A></td>"
							dat += "</tr>"
						dat += "</table>"

						dat += text("<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>")
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							dat += text("[]<BR><A href='?src=\ref[];choice=Delete Entry;del_c=[]'>Delete Entry</A><BR><BR>", active2.fields[text("com_[]", counter)], src, counter)
							counter++
						dat += text("<A href='?src=\ref[];choice=Add Entry'>Add Entry</A><BR><BR>", src)
						dat += text("<A href='?src=\ref[];choice=Delete Record (Security)'>Delete Record (Security Only)</A><BR><BR>", src)
					else
						dat += "<B>Security Record Lost!</B><BR>"
						dat += text("<A href='?src=\ref[];choice=New Record (Security)'>New Security Record</A><BR><BR>", src)
					dat += text("\n<A href='?src=\ref[];choice=Delete Record (ALL)'>Delete Record (ALL)</A><BR><BR>\n<A href='?src=\ref[];choice=Print Record'>Print Record</A><BR>", src, src)
				if(4.0)
					if(!Perp.len)
						dat += text("ERROR.  String could not be located.<br><br><A href='?src=\ref[];choice=Return'>Back</A>", src)
					else
						dat += {"
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>					"}
						dat += text("<th>Search Results for '[]':</th>", tempname)
						dat += {"
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Name</th>
<th>ID</th>
<th>Rank</th>
<th>Fingerprints</th>
<th>Criminal Status</th>
</tr>					"}
						for(var/i=1, i<=Perp.len, i += 2)
							var/crimstat = ""
							var/datum/data/record/R = Perp[i]
							if(istype(Perp[i+1],/datum/data/record/))
								var/datum/data/record/E = Perp[i+1]
								crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*Arrest*")
									background = "'background-color:#DC143C;'"
								if("Incarcerated")
									background = "'background-color:#CD853F;'"
								if("Parolled")
									background = "'background-color:#CD853F;'"
								if("Released")
									background = "'background-color:#3BB9FF;'"
								if("None")
									background = "'background-color:#00FF7F;'"
								if("")
									background = "'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += text("<tr style=[]><td><A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", background, src, R, R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
							dat += text("<td>[]</td></tr>", crimstat)
						dat += "</table><hr width='75%' />"
						dat += text("<br><A href='?src=\ref[];choice=Return'>Return to index.</A>", src)
				else
		else
			dat += {"<center>"}
			dat += {"<h1>Security Records</h1>"}
			dat += text("<A href='?src=\ref[];choice=Log In'>{Log In}</A>", src)
			dat += {"</center>"}
	//user << browse(text("<HEAD><TITLE>Security Records</TITLE></HEAD><TT>[]</TT>", dat), "window=secure_rec;size=600x400")
	//onclose(user, "secure_rec")
	var/datum/browser/popup = new(user, "secure_rec", "Security Records Console", 700, 600)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
		return
	if (!( data_core.general.Find(active1) ))
		active1 = null
	if (!( data_core.security.Find(active2) ))
		active2 = null
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		switch(href_list["choice"])
// SORTING!
			if("Sorting")
				// Reverse the order if clicked twice
				if(sortBy == href_list["sort"])
					if(order == 1)
						order = -1
					else
						order = 1
				else
				// New sorting order!
					sortBy = href_list["sort"]
					order = initial(order)
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if ("Return")
				screen = 1
				active1 = null
				active2 = null

			if("Log Out")
				authenticated = null
				rank = null
				screen = null
				active1 = null
				active2 = null

			if("Log In")
				if (istype(usr, /mob/living/silicon)) // AI and borgs can walk right in
					active1 = null
					active2 = null
					authenticated = "[usr.name]"
					rank = "AI"
					screen = 1
				if (istype(usr, /mob/living/carbon/human)) // Humans need authentication
					var/mob/living/carbon/human/user = usr
					if(src.allowed(user)) // Access allowed? ok lets get the ID information
						var/obj/item/H = usr.get_active_hand() // ID in a hand?
						if (istype(H, /obj/item/weapon/card/id))
							var/obj/item/weapon/card/id/R = H
							if(check_access(R))
								authenticated = R.registered_name
								rank = R.assignment
								screen = 1
								add_fingerprint(usr)
								updateUsrDialog()
								return
							else
								user << "<span class = 'info'>Access Denied!</span>"
								add_fingerprint(usr)
								updateUsrDialog()
								return
						var/obj/item/weapon/card/id/I = user.wear_id // ID/tablet/wallet in slot?
						if (istype(I, /obj/item/device/thinktronic/tablet))
							var/obj/item/device/thinktronic/tablet/pda = I
							I = pda.id
						if (istype(I, /obj/item/weapon/storage/wallet))
							var/obj/item/weapon/storage/wallet/wallet = I
							I = wallet.front_id
						if (I && istype(I))
							if(src.check_access(I))
								authenticated = I.registered_name
								rank = I.assignment
								screen = 1
					else
						user << "<span class = 'info'>Access Denied!</span>"
				/*
				else if (istype(scan, /obj/item/weapon/card/id))
					active1 = null
					active2 = null
					if(check_access(scan))
						authenticated = authenticated
						rank = scan.assignment
						screen = 1
				*/
//RECORD FUNCTIONS
			if("Search Records")
				var/t1 = input("Search String: (Partial Name or ID or Fingerprints or Rank)", "Secure. records", null, null)  as text
				if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || !in_range(src, usr)))
					return
				Perp = new/list()
				t1 = lowertext(t1)
				var/list/components = text2list(t1, " ")
				if(components.len > 5)
					return //Lets not let them search too greedily.
				for(var/datum/data/record/R in data_core.general)
					var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["fingerprint"] + " " + R.fields["rank"]
					for(var/i = 1, i<=components.len, i++)
						if(findtext(temptext,components[i]))
							var/prelist = new/list(2)
							prelist[1] = R
							Perp += prelist
				for(var/i = 1, i<=Perp.len, i+=2)
					for(var/datum/data/record/E in data_core.security)
						var/datum/data/record/R = Perp[i]
						if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
							Perp[i+1] = E
				tempname = t1
				screen = 4

			if("Record Maintenance")
				screen = 2
				active1 = null
				active2 = null

			if ("Browse Record")
				var/datum/data/record/R = locate(href_list["d_rec"])
				var/S = locate(href_list["d_rec"])
				if (!( data_core.general.Find(R) ))
					temp = "Record Not Found!"
				else
					for(var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
							S = E
					active1 = R
					active2 = S
					screen = 3

/*			if ("Search Fingerprints")
				var/t1 = input("Search String: (Fingerprint)", "Secure. records", null, null)  as text
				if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || (!in_range(src, usr)) && (!istype(usr, /mob/living/silicon))))
					return
				active1 = null
				active2 = null
				t1 = lowertext(t1)
				for(var/datum/data/record/R in data_core.general)
					if (lowertext(R.fields["fingerprint"]) == t1)
						active1 = R
				if (!( active1 ))
					temp = text("Could not locate record [].", t1)
				else
					for(var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == active1.fields["name"] || E.fields["id"] == active1.fields["id"]))
							active2 = E
					screen = 3	*/

			if ("Print Record")
				if (!( printing ))
					printing = 1
					data_core.securityPrintCount++
					sleep(50)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( loc )
					P.info = "<CENTER><B>Security Record - (SR-[data_core.securityPrintCount])</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", active1.fields["name"], active1.fields["id"], active1.fields["sex"], active1.fields["age"], active1.fields["fingerprint"], active1.fields["p_stat"], active1.fields["m_stat"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
					if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						P.info += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []", active2.fields["criminal"])

						P.info += "<BR>\n<BR>\nMinor Crimes:<BR>\n"
						P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["min_crim"])
							P.info += "<tr><td>[c.crimeName]</td>"
							P.info += "<td>[c.crimeDetails]</td>"
							P.info += "<td>[c.author]</td>"
							P.info += "<td>[c.time]</td>"
							P.info += "</tr>"
						P.info += "</table>"

						P.info += "<BR>\nMedium Crimes: <BR>\n"
						P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["med_crim"])
							P.info += "<tr><td>[c.crimeName]</td>"
							P.info += "<td>[c.crimeDetails]</td>"
							P.info += "<td>[c.author]</td>"
							P.info += "<td>[c.time]</td>"
							P.info += "</tr>"
						P.info += "</table>"

						P.info += "<BR>\nMajor Crimes: <BR>\n"
						P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["maj_crim"])
							P.info += "<tr><td>[c.crimeName]</td>"
							P.info += "<td>[c.crimeDetails]</td>"
							P.info += "<td>[c.author]</td>"
							P.info += "<td>[c.time]</td>"
							P.info += "</tr>"
						P.info += "</table>"

						P.info += "<BR>\nCapital Crimes: <BR>\n"
						P.info +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
						for(var/datum/data/crime/c in active2.fields["cap_crim"])
							P.info += "<tr><td>[c.crimeName]</td>"
							P.info += "<td>[c.crimeDetails]</td>"
							P.info += "<td>[c.author]</td>"
							P.info += "<td>[c.time]</td>"
							P.info += "</tr>"
						P.info += "</table>"

						P.info += "<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", active2.fields[text("com_[]", counter)])
							counter++
					else
						P.info += "<B>Security Record Lost!</B><BR>"
					P.info += "</TT>"
					P.name = text("SR-[] '[]'", data_core.securityPrintCount, active1.fields["name"])
					printing = null
//RECORD DELETE
			if ("Delete All Records")
				temp = ""
				temp += "Are you sure you wish to delete all Security records?<br>"
				temp += "<a href='?src=\ref[src];choice=Purge All Records'>Yes</a><br>"
				temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Purge All Records")
				for(var/datum/data/record/R in data_core.security)
					del(R)
				temp = "All Security records deleted."

			if ("Add Entry")
				if (!( istype(active2, /datum/data/record) ))
					return
				var/a2 = active2
				var/t1 = copytext(sanitize(input("Add Comment:", "Secure. records", null, null)  as message),1,MAX_MESSAGE_LEN)
				if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
					return
				var/counter = 1
				while(active2.fields[text("com_[]", counter)])
					counter++
				active2.fields[text("com_[]", counter)] = text("Made by [] ([]) on [] [], []<BR>[]", src.authenticated, src.rank, worldtime2text(), time2text(world.realtime, "MMM DD"), year_integer+540, t1,)
				broadcast_hud_message("[src.authenticated] added comment to: [active1.fields["name"]] - [t1]", src)
				crimelogs.Add("BRIG: [key_name(usr)] added comment to: [active1.fields["name"]] - [t1]") // For crime log purposes
				log_game("BRIG: [key_name(usr)] added comment to: [active1.fields["name"]] - [t1]") // For crime LOG purposes

			if ("Delete Record (ALL)")
				if (active1)
					temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Delete Record (Security)")
				if (active2)
					temp = "<h5>Are you sure you wish to delete the record (Security Portion Only)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (Security) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Delete Entry")
				if ((istype(active2, /datum/data/record) && active2.fields[text("com_[]", href_list["del_c"])]))
					active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"
//RECORD CREATE
			if ("New Record (Security)")
				if ((istype(active1, /datum/data/record) && !( istype(active2, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record()
					R.fields["name"] = active1.fields["name"]
					R.fields["id"] = active1.fields["id"]
					R.name = text("Security Record #[]", R.fields["id"])
					R.fields["criminal"] = "None"
					R.fields["min_crim"] = list()
					R.fields["med_crim"] = list()
					R.fields["maj_crim"] = list()
					R.fields["cap_crim"] = list()
					R.fields["notes"] = "No notes."
					data_core.security += R
					active2 = R
					screen = 3

			if ("New Record (General)")
				var/datum/data/record/G = new /datum/data/record()
				G.fields["name"] = "New Record"
				G.fields["id"] = "[num2hex(rand(1, 1.6777215E7), 6)]"
				G.fields["rank"] = "Unassigned"
				G.fields["sex"] = "Male"
				G.fields["age"] = "Unknown"
				G.fields["fingerprint"] = "Unknown"
				G.fields["p_stat"] = "Active"
				G.fields["m_stat"] = "Stable"
				data_core.general += G
				active1 = G
				active2 = null

//FIELD FUNCTIONS
			if ("Edit Field")
				var/a1 = active1
				var/a2 = active2
				switch(href_list["field"])
					if("name")
						if (istype(active1, /datum/data/record))
							var/t1 = input("Please input name:", "Secure. records", active1.fields["name"], null)  as text
							if ((!( t1 ) || !length(trim(t1)) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon)))) || active1 != a1)
								return
							active1.fields["name"] = t1
					if("id")
						if (istype(active2, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input id:", "Secure. records", active1.fields["id"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["id"] = t1
					if("fingerprint")
						if (istype(active1, /datum/data/record))
							var/t1 = copytext(sanitize(input("Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"], null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["fingerprint"] = t1
					if("sex")
						if (istype(active1, /datum/data/record))
							if (active1.fields["sex"] == "Male")
								active1.fields["sex"] = "Female"
							else
								active1.fields["sex"] = "Male"
					if("age")
						if (istype(active1, /datum/data/record))
							var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["age"] = t1
					if("min_crim_add")
						if (istype(active1, /datum/data/record))
							//var/t1 = copytext(sanitize(input("Please input minor crime names:", "Secure. records", "", null)  as text),1,MAX_MESSAGE_LEN)
							//Crime Input begin
							var/list/D = list()
							D["Cancel"] = "Cancel"
							for(var/datum/crime/minor/crime in crimes)
								D["[crime.name]"] = crime.name
							var/spamcheck = 0
							if(spamcheck) return
							spamcheck = 1
							var/t1 = input(usr, "Which crime would you like to add?") as null|anything in D
							spamcheck = 0
							if(!t1)
								return
							if(t1 == "Cancel")
								return
							//Crime input end
							var/t2 = copytext(sanitize(input("Please input minor crime details:", "Secure. records", "", null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( t2 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							var/crime = data_core.createCrimeEntry(t1, t2, authenticated ? authenticated : "Unknown", worldtime2text(), active1.fields["name"], src)
							data_core.addMinorCrime(active1.fields["id"], crime)
							crimelogs.Add("RECORDS: [key_name(usr)] added [t1] to [active1.fields["name"]] - [t2]") // For crime log purposes
							log_game("BRIG: [key_name(usr)] added [t1] to [active1.fields["name"]] - [t2]") // For crime LOG purposes
					if("min_crim_delete")
						if (istype(active1, /datum/data/record))
							if (href_list["cdataid"])
								if ((!( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
									return
								data_core.removeMinorCrime(active1.fields["id"], href_list["cdataid"])
					if("med_crim_add")
						if (istype(active1, /datum/data/record))
							//var/t1 = copytext(sanitize(input("Please input medium crime names:", "Secure. records", "", null)  as text),1,MAX_MESSAGE_LEN)
							//Crime Input begin
							var/list/D = list()
							D["Cancel"] = "Cancel"
							for(var/datum/crime/medium/crime in crimes)
								D["[crime.name]"] = crime.name
							var/spamcheck = 0
							if(spamcheck) return
							spamcheck = 1
							var/t1 = input(usr, "Which crime would you like to add?") as null|anything in D
							spamcheck = 0
							if(!t1)
								return
							if(t1 == "Cancel")
								return
							//Crime input end
							var/t2 = copytext(sanitize(input("Please input medium crime details:", "Secure. records", "", null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( t2 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							var/crime = data_core.createCrimeEntry(t1, t2, authenticated ? authenticated : "Unknown", worldtime2text(), active1.fields["name"], src)
							data_core.addMediumCrime(active1.fields["id"], crime)
							crimelogs.Add("RECORDS: [key_name(usr)] added [t1] to [active1.fields["name"]] - [t2]") // For crime log purposes
							log_game("BRIG: [key_name(usr)] added [t1] to [active1.fields["name"]] - [t2]") // For crime LOG purposes
					if("med_crim_delete")
						if (istype(active1, /datum/data/record))
							if (href_list["cdataid"])
								if ((!( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
									return
								data_core.removeMediumCrime(active1.fields["id"], href_list["cdataid"])
					if("maj_crim_add")
						if (istype(active1, /datum/data/record))
							//var/t1 = copytext(sanitize(input("Please input major crime names:", "Secure. records", "", null)  as text),1,MAX_MESSAGE_LEN)
							//Crime Input begin
							var/list/D = list()
							D["Cancel"] = "Cancel"
							for(var/datum/crime/major/crime in crimes)
								D["[crime.name]"] = crime.name
							var/spamcheck = 0
							if(spamcheck) return
							spamcheck = 1
							var/t1 = input(usr, "Which crime would you like to add?") as null|anything in D
							spamcheck = 0
							if(!t1)
								return
							if(t1 == "Cancel")
								return
							//Crime input end
							var/t2 = copytext(sanitize(input("Please input major crime details:", "Secure. records", "", null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( t2 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							var/crime = data_core.createCrimeEntry(t1, t2, authenticated ? authenticated : "Unknown", worldtime2text(), active1.fields["name"], src)
							data_core.addMajorCrime(active1.fields["id"], crime)
							crimelogs.Add("RECORDS: [key_name(usr)] added [t1] to [active1.fields["name"]] - [t2]") // For crime log purposes
							log_game("BRIG: [key_name(usr)] added [t1] to [active1.fields["name"]] - [t2]") // For crime LOG purposes
					if("maj_crim_delete")
						if (istype(active1, /datum/data/record))
							if (href_list["cdataid"])
								if ((!( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
									return
								data_core.removeMajorCrime(active1.fields["id"], href_list["cdataid"])
					if("cap_crim_add")
						if (istype(active1, /datum/data/record))
							//var/t1 = copytext(sanitize(input("Please input capital crime names:", "Secure. records", "", null)  as text),1,MAX_MESSAGE_LEN)
							//Crime Input begin
							var/list/D = list()
							D["Cancel"] = "Cancel"
							for(var/datum/crime/capital/crime in crimes)
								D["[crime.name]"] = crime.name
							var/spamcheck = 0
							if(spamcheck) return
							spamcheck = 1
							var/t1 = input(usr, "Which crime would you like to add?") as null|anything in D
							spamcheck = 0
							if(!t1)
								return
							if(t1 == "Cancel")
								return
							//Crime input end
							var/t2 = copytext(sanitize(input("Please input capital crime details:", "Secure. records", "", null)  as text),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( t2 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							var/crime = data_core.createCrimeEntry(t1, t2, authenticated ? authenticated : "Unknown", worldtime2text(), active1.fields["name"], src)
							data_core.addCapitalCrime(active1.fields["id"], crime)
							crimelogs.Add("RECORDS: [key_name(usr)] added [t1] to [active1.fields["name"]] - [t2]") // For crime log purposes
							log_game("BRIG: [key_name(usr)] added [t1] to [active1.fields["name"]] - [t2]") // For crime LOG purposes
					if("cap_crim_delete")
						if (istype(active1, /datum/data/record))
							if (href_list["cdataid"])
								if ((!( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
									return
								data_core.removeCapitalCrime(active1.fields["id"], href_list["cdataid"])
					if("criminal")
						if (istype(active2, /datum/data/record))
							temp = "<h5>Criminal Status:</h5>"
							temp += "<ul>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=none'>None</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=arrest'>*Arrest*</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=incarcerated'>Incarcerated</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=parolled'>Parolled</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=released'>Released</a></li>"
							temp += "</ul>"
					if("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI" )
						//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
						if ((istype(active1, /datum/data/record) && L.Find(rank)))
							temp = "<h5>Rank:</h5>"
							temp += "<ul>"
							for(var/rank in get_all_jobs())
								temp += "<li><a href='?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
							temp += "</ul>"
						else
							alert(usr, "You do not have the required rank to do this!")
//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
				switch(href_list["choice"])
					if ("Change Rank")
						if (active1)
							active1.fields["rank"] = href_list["rank"]
							if(href_list["rank"] in get_all_jobs())
								active1.fields["real_rank"] = href_list["real_rank"]

					if ("Change Criminal Status")
						if (active2)
							switch(href_list["criminal2"])
								if("none")
									active2.fields["criminal"] = "None"
								if("arrest")
									active2.fields["criminal"] = "*Arrest*"
								if("incarcerated")
									active2.fields["criminal"] = "Incarcerated"
								if("parolled")
									active2.fields["criminal"] = "Parolled"
								if("released")
									active2.fields["criminal"] = "Released"
							broadcast_hud_message("[active1.fields["name"]] has been set to [active2.fields["criminal"]]", src)
							crimelogs.Add("RECORDS: [key_name(usr)] set [active1.fields["name"]] to [active2.fields["criminal"]]") // For crime log purposes
							log_game("BRIG: [key_name(usr)] set [active1.fields["name"]] to [active2.fields["criminal"]]") // For crime LOG purposes

					if ("Delete Record (Security) Execute")
						if (active2)
							del(active2)

					if ("Delete Record (ALL) Execute")
						if (active1)
							for(var/datum/data/record/R in data_core.medical)
								if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
									del(R)
								else
							del(active1)
						if (active2)
							del(active2)
					else
						temp = "This function does not appear to be working at the moment. Our apologies."

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/secure_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in data_core.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = "[pick(pick(first_names_male), pick(first_names_female))] [pick(last_names)]"
				if(2)
					R.fields["sex"]	= pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Parolled", "Released")
				if(5)
					R.fields["p_stat"] = pick("*Unconcious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			del(R)
			continue

	..(severity)

/obj/machinery/computer/secure_data/detective_computer
	icon = 'icons/obj/computer.dmi'
	icon_state = "messyfiles"