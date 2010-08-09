
local MAJOR = "LibMarquee-1.0" 
local MINOR = 1
assert(LibStub, MAJOR.." requires LibStub") 
local LibMarquee = LibStub:NewLibrary(MAJOR, MINOR)
if not LibMarquee then return end

local LibProperty = LibStub("LibProperty-1.0")

local PINGPONGWAIT = 2
local ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_MARQUEE, ALIGN_AUTOMATIC, ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6
local SCROLL_RIGHT, SCROLL_LEFT = 1, 2


if not LibMarquee.__index then
	LibMarquee.__index = LibMarquee
	LibMarquee.pool = setmetatable({}, {__mode = "k"})
end

local function resizeText(str, cols)
	if len(str) < cols then
		for i = strlen(str), cols do
			str = str + " "
		end
	end
	return str:sub(cols)
end

function LibMarquee:New(fontString, env, name, string, cols, prefix, postfix, precision, align, update, scroll, speed, direction) 

	self.value = LibProperty:New(env, name .. " string", string) -- text of marquee
	self.prefix = LibProperty:New(env, name .. " prefix", prefix) -- label on the left side
	self.postfix = LibProperty:New(env, name .. " postfix", postfix) -- label on right side
	self.precision = precision or 0xBABE -- number of digits after the decimal point
	self.align = align or ALIGN_LEFT -- alignment: left, center, right, marquee, automatic
	self.update = update or 500 -- update interval
	self.scroll = 0 -- marquee starting point
	self.speed = speed or 500 -- marquee scrolling speed
	self.direction = direction or SCROLL_RIGHT -- pingpong direction, 0 = right, 1 = left
	self.cols = length or 20 -- number of colums in marquee
	self.offset = 0 -- increment by pixel
	self.string = "" -- formatted value

	local obj = next(self.pool)

	if obj then
		self.pool[obj] = nil
	else
		obj = {}
	end

	setmetatable(obj, self)
	
	return obj	
end

function LibMarquee:Del(ev)
	LibMarquee.pool[ev] = true
end

function LibMarquee:DrawDone()
	-- fire event
	self.draw = false
end



function LibMarquee:TextScroll()

	local pre = self.prefix:P2S()
	local post = self.postfix:PS2()

	local str = self.string

	local num, len, width, pad
	local srcPtr, dstPtr = 0, 0
	local src = ""
	local dst = ""
	

    num = 0;
    len = strlen(str)
    width = cols_ - strlen(pre) - strlen(post);
    if width < 0 then
        width = 0
	end

    if self.direction == SCROLL_RIGHT and (self.align == ALIGN_MARQUEE or self.align == ALIGN_PINGPONG or self.align == ALIGN_AUTOMATIC) then
		self.offset = self.offset + 1
    elseif (self.align == ALIGN_MARQUEE or self.align == ALIGN_PINGPONG or self.align == ALIGN_AUTOMATIC) then
		self.offset = self.offset - 1
	end

    if(abs(offset_) <= self.cols and (self.align == ALIGN_MARQUEE or self.align == ALIGN_PINGPONG or (self.align == ALIGN_AUTOMATIC and len > width))) then
		self.draw = true
        return
    else
        self.offset = 0;
    end

	if self.align == ALIGN_LEFT then
		pad = 0
	elseif self.align == ALIGN_CENTER then
		pad = (width - len) / 2
		if pad < 0 then
			pad = 0
		end
	elseif self.align == ALIGN_RIGHT then
		pad = width - len
		if pad < 0 then
			pad = 0
		end
	elseif self.align == ALIGN_AUTOMATIC then
		if len <= width then
			pad = 0
		end
	elseif self.align == ALIGN_MARQUEE then
		pad = width - self.scroll
		self.scroll = self.scroll + 1
		if self.scroll >= width + len then
			self.scroll = self.cols
		end
	elseif self.align == ALIGN_PINGPONG then
		if len <= width then
			pad = (width - len) / 2
		else
			if self.direction == SCROLL_RIGHT then
				self.scroll = self.scroll + 1
			else
				self.scroll = self.scroll - 1
			end
			
			pad = 0 - scroll_;
			
			if pad < 0 - (len - width) then
				if self.delay < 1 then
					self.direction = SCROLL_LEFT
					self.delay = PINGPONGWAIT
					self.scroll = self.scroll - PINGPONGWAIT
				end
				pad = 0 - (len - width)
			elseif pad > 0 then
				if self.delay < 1 then
					self.direction = SCROLL_RIGHT
					self.delay = PINGPONGWAIT
					self.scroll = self.scroll + PINGPOINGWAIT
				end
				pad = 0
			else
				pad = 0
			end
		end
	end

	resizeText(dst, self.cols)
	
    dstPtr = 0;
    num = 0;

    -- /* process prefix */
    src = pre;
    while (num < self.cols) do
        if (srcPtr == strlen(src)) then
            break
		end
        dst[dstPtr] = src[srcPtr];
		dstPtr = dstPtr + 1
		srcPtr = srcPtr + 1
        num = num + 1
    end

    src = str;
    srcPtr = 0;

	local offset = pad
	
    if(offset < 0) then
        offset = 0;
	end
	
    -- /* wrap around on the beginning */
    while (pad > 0 and num < self.cols) do
        if(self.align == ALIGN_MARQUEE) then
            dst[dstPtr] = src[(strlen(src) - offset) + srcPtr];
			dstPtr = dstPtr + 1
			srcPtr = srcPtr + 1
        else
            dst[dstPtr] = ' ';
		end
		dstPtr = dstPtr + 1
        num = num + 1
        pad = pad - 1
    end

    --/* skip src chars (marquee) */
	local tmp = src
    while (pad < 0 and tmp ~= "") do
        src = tmp:sub(1); 
        tmp = src;
        pad = pad + 1
    end


    --/* copy content */
    while (num < cols_) do
        if (srcPtr >= strlen(src)) then
            break;
		end
        dst[dstPtr] = src[srcPtr];
		dstPtr = dstPtr + 1
		srcPtr = srcPtr + 1
        num = num + 1
    end

    -- wrap around on end 
    src = post;
    len = strlen(src)
    srcPtr = 0;
    if(num < self.cols - len and self.align == ALIGN_MARQUEE) then
        dst[dstPtr] = '*';
		dstPtr = dstPtr + 1
        num = num + 1
    end
    while (num < self.cols - len) do
        if(self.align == ALIGN_MARQUEE) then
            dst[dstPtr] = str[srcPtr];
			dstPtr = dstPtr + 1
			srcPtr = srcPtr + 1
        else
            dst[dstPtr] = ' ';
			dstPtr = dstPtr + 1
		end
        num = num + 1;
    end

    srcPtr = 0;

    --/* process postfix */
    while (num < cols_) do
        if (srcPtr >= strlen(src)) then
            break;
		end
        dst[dstPtr] = src[srcPtr];
		dstPtr = dstPtr + 1
		srcPtr = srcPtr + 1
        num = num + 1
    end

	self.buffer = dst
	
	self.draw = true
end


function LibMarquee:Update()
	local str
	local update = 0
	
	update = update + self.prefix:Eval()
	update = update + self.postfix:Eval()

	self.value:Eval()
	
    -- /* str or number? */
    if (precision_ == 0xBABE) then
        str = self.value:P2S();
    else
        local number = self.value:P2N();
        local width = self.cols - strlen(prefix:P2S()) - strlen(postfix:P2S());
        local precision = self.precision;
        --[[/* print zero bytes so we can specify NULL as target  */
        /* and get the length of the resulting str */]]
		local text = ("%.*f"):format(precision, number)
		local size = strlen(text)
        --/* number does not fit into field width: try to reduce precision */
        if (width < 0) then
            width = 0;
		end
        if (size > width and precision > 0) then
            local delta = size - width;
            if (delta > precision) then
                delta = precision;
			end
            precision = precision - delta;
            size = size - delta;
            --/* zero precision: omit decimal point, too */
            if (precision == 0) then
                size = size - 1
			end
        end
        ---/* number still doesn't fit: display '*****'  */
        if (size > width) then
            str.resize(width);
            for i = 0, width do
                str[i] = '*';
			end
        else
            str = text
        end
    end

    if str == "" or str ~= self.string then 
        update = update + 1;
        self.string = str;
    end

    --/* something has changed and should be updated */
    if (update > 0) then

		
        -- /* Init pingpong scroller. start scrolling left (wrong way) to get a delay */
        if (self.align == ALIGN_PINGPONG) then
            self.direction = 0;
            self.delay = PINGPONGWAIT;
        end
		--[[
        /* if there's a marquee scroller active, it has its own */
        /* update callback timer, so we do nothing here; otherwise */
        /* we simply call this scroll callback directly */
		]]
        if (self.align ~= ALIGN_MARQUEE or self.align ~= ALIGN_AUTOMATIC or self.align ~= ALIGN_PINGPONG) then
            self:TextScroll()
        end

    end

end
