WINSIZE = CCDirector:sharedDirector():getWinSize()
function P(fileName)
	if fileName then
		return ScutDataLogic.CFileHelper:getPath(fileName)
	else
		return nil
	end
end

