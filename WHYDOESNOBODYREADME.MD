----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

# BOII | Development - Utility: Job Center

Introducing a nice and simple job center UI to allow you citizens to accept new jobs, including a built in rep system.
The script is aimed to be as simple as possible to allow for customisation with minimal coding experience required.
Crafted with precision and adaptability in mind, this script integrates seamlessly with multiple frameworks, ensuring a smooth experience for all server setups.
Complete installation guidelines are provided to ensure easy setup and integration.
Enjoy! 

### Dependencies

- Frameworks: `boii_base`, `qb-core`, `esx_legacy` are currently supported. For custom framework integration, utilize the bridge functions provided.
- PolyZone: this is currently required for job center zones, will be updated to target a.s.a.p
- OxMySQL: this is currently required support for alternate sql wrappers may be added in requested

### Optional Resources

- boii_ui - https://github.com/boiidevelopment/boii_ui

### Install

1. **Script Customisation**:
   
   - Adjust `shared/config.lua` according to your requirements. This is the hub for framework and general configurations.
   - Modify the language files in `shared/language/` as needed. For additional languages, create a new file and follow the guidance within `fxmanifest.lua`.
   - Modify the UI language in the `html/scripts/language/*.json` files, and you can change the default language in `scripts/js/main.js` look for `chosen_language`

2. **Custom Frameworks**: *(Skip if using one of the bundled frameworks)*

   - Modify the `framework.lua` files in both client and server directories to match your custom framework's needs. Stick to the events/functions shown in the provided framework samples to ensure compatibility.

3. **Script Installation**:

   - Import `boii_jobcenter` into your server resource and ensure the load order is correct. Refer to the image below for guidance on load order.

    ![image](https://cdn.discordapp.com/attachments/900123174669279284/969505774575435786/LOADORDER.jpg?ex=651335dd&is=6511e45d&hm=d7e7dc56675feadea2ad07d447df2429e9e052d8bc0049c16bbb3665650a6a51&)

   - If your server doesn't utilize categorized folders, add `ensure boii_jobcenter` to your `server.cfg`.

4. **Restart Server**:
   
   - Having followed the above steps, restart your server, and voilà! Your Job Center utility should be up and running.


### API

Get Reputation:

```lua
exports['boii_jobcenter']:get_reputation(_src --[[source player]], job_name --[[name of job]])
```

Modify Reputation:

```lua
exports['boii_jobcenter']:modify_reputation(_src --[[source player]], job_name --[[name of job]], value --[[amount of rep to add/remove/set]], operation --[['add', 'remove' or 'set' can be used]])
```

### PREVIEW
https://www.youtube.com/watch?v=U64QlrqVUc0

### SUPPORT
https://discord.gg/boiidevelopment