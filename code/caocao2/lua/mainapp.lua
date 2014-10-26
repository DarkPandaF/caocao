math.randomseed(os.time())

function initPackagePath()
	local m_package_path = package.path
	local tInfo = {}
	local p1 = ScutDataLogic.CFileHelper:getPath("lua")
	table.insert(tInfo, string.format("%s/?.lua;", p1))
	table.insert(tInfo, string.format("%s/battle/?.lua;", p1))
	table.insert(tInfo, string.format("%s/common/?.lua;", p1))

	local p2 = CCFileUtils:sharedFileUtils():fullPathForFilename("lua")
	table.insert(tInfo, string.format("%s/?.lua;", p2))
	table.insert(tInfo, string.format("%s/battle/?.lua;", p2))
	table.insert(tInfo, string.format("%s/common/?.lua;", p2))

	table.insert(tInfo, string.format("%s", m_package_path))
	local strPath = nil
	for k, v in pairs(tInfo) do
		if strPath == nil then
			strPath = v
		else
			strPath = strPath .. v
		end
	end
	package.path = strPath
end
initPackagePath()



function OnHandleData(pScene, nTag, nNetRet, pData, lpExternal)
	pScene = tolua.cast(pScene, "CCScene")
	g_scenes[pScene]:execCallback(nTag, nNetRet, pData)
end

function PushReceiverCallback(pScene, lpExternalData)

end

function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end



function main() 
    
    require("common.common")
    require("battle.battle")
    
    

	collectgarbage("setpause", 150)
    collectgarbage("setstepmul", 1000)
	
	 
	local sceneGame = BattleScene.new()
	runningScene = CCDirector:sharedDirector():getRunningScene()
   
	if runningScene == nil then
		CCDirector:sharedDirector():runWithScene(sceneGame)
	else
		CCDirector:sharedDirector():replaceScene(sceneGame)
	end
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end