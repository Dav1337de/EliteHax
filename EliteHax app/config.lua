local model = system.getInfo("model")
local myData = require ("mydata")

if ( string.sub( model, 1, 4 ) == "iPad" ) then
	application = 
	{
		content = 
		{
			width = 768,
			height = 1024,
			--width = 360,
			--height = 480,
			scale = "zoomEven",
			xAlign = "left",
			yAlign = "center",
			fps = 60,
		}
	}
else
	application = 
	{
        license =
        {
            google =
            {
            	--GitHub Note: Insert your key
                key = "XXX",
            },			
        },
		content = 
		{
			width = 1080,
			height = 1920,
			--width = 360,
			--height = 480,
			scale = "zoomEven",
			xAlign = "left",
			yAlign = "center",
			fps = 60,
		}
	}
end