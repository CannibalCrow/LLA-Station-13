/obj/item/device/thinktronic_parts/program/sci/researchmonitor
	name = "Research Monitor"
	usealerts = 1
	var/obj/machinery/computer/rdconsole/cons = null

	New()
		for(var/obj/machinery/computer/rdconsole/core/M in world)
			cons = M
			break

	use_app() //Put all the HTML here
		if(network())
			var/datum/research/file = cons.files
			if(file)
				dat = "<h3>Current Research Levels:</h3><BR><div class='statusDisplay'>"
				for(var/datum/tech/T in file.known_tech)
					dat += "[T.name]<BR>"
					dat +=  "* Level: [T.level]<BR>"
					dat +=  "* Summary: [T.desc]<HR>"
				dat += "</div>"
			else
				dat += "ERROR: no research found in server"
