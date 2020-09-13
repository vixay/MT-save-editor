LUA CODE TO add card
local str=allocateMemory(100)
writeInteger(str+0x10,36)
writeString(str+0x14,'1450e56b-ca09-453a-937a-97bd44bcb3de',true)
LaunchMonoDataCollector()
mono_invoke_method('',mono_findMethod('', 'CheatManager', 'Command_AddCard'), 0,{{type=vtPointer,value=str}})
deAlloc(str)

LUA CODE TO ADD GOLD
local str=allocateMemory(100)
writeInteger(str+0x10,8)
writeString(str+0x14,'10000',true)
LaunchMonoDataCollector()
mono_invoke_method('',mono_findMethod('', 'CheatManager', 'Command_AdjustGold'), 0,{{type=vtPointer,value=str}})
deAlloc(str)