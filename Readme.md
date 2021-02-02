Source of csv files 
https://docs.google.com/spreadsheets/d/1YPfFN88ss1Ye-j6M5HehKf-NxuIJHrfA-75xeSVKMQY/edit#gid=1244805614

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

A single Card Details

        {
            "cardDataID": "9f4dd6b6-4a03-4e2d-9a52-8a17b1dd2c93",
            "cardModifiers": {
                "additionalDamage": 0,
                "additionalMaxHP": 0,
                "additionalCost": 0,
                "additionalXCost": 0,
                "additionalHeal": 0,
                "additionalSize": 0,
                "cardTraitReplacements": [],
                "cardUpgrades": []
            }
        },
