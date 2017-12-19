local cjson = require("cjson")  
--/ * *
--* 时 间 ： 2017 / 12 / 18
--* 作 者 :  liulin
--* 功 能 :  打开文件读取数据,返回文件数据
-- -- * /
function get_file_info(file_name) 
	local f      = assert(io.open(file_name, 'r'))
	local string = f:read("*all")
    f:close()
    return string
end

--/ * *
--* 时 间 ： 2017 / 12 / 18
--* 作 者 :  liulin
--* 功 能 :  向文件中写入数据
-- -- * /
function write_file(file_name,string)
    local f = assert(io.open(file_name, 'w'))
    f:write(string)
    f:close()
end

-- 
--/ * *
--* 时 间 ： 2017 / 12 / 18
--* 作 者 :  liulin
--* 功 能 :  指定文件夹查找文件,返回一个table
-- -- * /
function find_file_by_name(dir_name,file_name)

	get_factory_pid     = io.popen('find '..dir_name..' -name ' .. file_name)
	factory_pid_table   = {};

	for file in get_factory_pid:lines() do 
		if string.find(file,file_name) then
			--print(file)
			table.insert(factory_pid_table,file);
		end
	end
	print("factory_PID count is :"..#factory_pid_table);
	return factory_pid_table
	
end

--/ * *
--* 时 间 ： 2017 / 12 / 18
--* 作 者 :  liulin
--* 功 能 :  解析字符串
-- -- * /
function parse_string(factory_pid_string)
	-- body
	local _,end_flag  = string.find(factory_pid_string,"]")
	local string      = string.sub(factory_pid_string,2,end_flag-1)
	local factory_obj = cjson.decode(string)

	if(factory_obj) then
		local vendor        = factory_obj.LICENCE_USER --供应商
		local version       = factory_obj.PRODUCT_NAME --型号	
		return vendor,version
	end

end
--/ * *
--* 时 间 ： 2017 / 12 / 19 
--* 作 者 :  liulin
--* 功 能 :  处理主函数
-- -- * /
function do_main(file_dir,file_name,generate_dir)

	local file_list     = find_file_by_name(file_dir,file_name)
	local factory_table = {}
	local version_table = {}
	local vendor_bak    = {}

	for i,v in ipairs(file_list) do
		local file_info      = get_file_info(v)
		local vendor,version = parse_string(file_info)
		local  flag          = 0                     -- 修改标志位

		for i=1,#(factory_table) do
			if(factory_table[i]["vendor"] == vendor and factory_table[i]["vendor"] ~= "") then
				--print(vendor..'==========='..version)
				flag = 1
				table.insert(vendor_bak,vendor)

				if(version) then
			 		--print("++++++++向对应供应商添加型号++++++")
					table.insert(factory_table[i]["version"],version)
				end
			end
		end

		if(flag == 0) then
			--print("-----没有找到供应商-------")
			version_table = {}
			table.insert(version_table,version) 
			table.insert(factory_table, { vendor = vendor, version = version_table}) 
		end
	end

	local jsonStr        = cjson.encode(factory_table)
	local vender_bak_str = cjson.encode(vendor_bak)
	--print(vender_bak_str)
	--路径  /home/liulin/zk_openwrt/zk_openwrt/openwrt/products
	write_file(generate_dir,jsonStr)
end

do_main("/home/liulin/zk_openwrt/zk_openwrt/openwrt/products","factory_PID","vendor_product.json")

