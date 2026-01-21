function descriptor()
    return {
        title = "Play Next in Folder";
        version = "1.1";
        author = "Mindconstructor/RSC";
        url = 'http://www.videolan.org';
        shortdesc = "Play Next in Folder";
        description = "This extension plays the next media file in the directory of the last ended video file.";
        capabilities = {"input-listener","meta-listener","playing-listener"}
    }
end

function activate()
    vlc.msg.info("[Play Next in Folder] Activated")
end

function deactivate()
    vlc.msg.info("[Play Next in Folder] Deactivated")
end

local lastplayeditem = ""

function meta_changed()
	vlc.msg.info("NXT:Meta changed!",vlc.playlist.status())
    local item = vlc.input.item()
       if item then
           lastplayeditem = item:uri()
		   vlc.msg.info("Item:",lastplayeditem)
       end
    
end

function playing_changed()
	vlc.msg.info("NXT:Playing changed!",vlc.playlist.status())
    local item = vlc.input.item()
    if item then
		lastplayeditem = item:uri()
        vlc.msg.info("Item:",lastplayeditem)
    end
end

function input_changed()
	vlc.msg.info("NXT:Input changed!",vlc.playlist.status(),lastplayeditem)
    -- Trigger only when playback stops
    if vlc.playlist.status() == "stopped" then
        local path = vlc.strings.make_path(lastplayeditem)
        play_next_video_in_directory(path)
    end
end

function status_changed()
vlc.msg.info("NXT:Status changed!",lastplayeditem)
    -- Trigger only when playback stops
    if vlc.playlist.status() == "stopped" then
        local uri = lastplayeditem
        local path = vlc.strings.decode_uri(uri)
        play_next_video_in_directory(path)
    end
end

function play_next_video_in_directory(current_path)
	vlc.msg.info("NXT:current_path:" , current_path)
	local normalized_path = current_path:gsub("\\", "/")
	vlc.msg.info("NXT:normalized_path:" , normalized_path)
    local folder_path = normalized_path:match("^(.*)/.*$")
	vlc.msg.info("NXT:folder_path:" , folder_path)
    if not folder_path then return end

    local files = vlc.io.readdir(folder_path)
    if not files then return end

    -- Filter for media files
 --   files = filter_media_files(files)

    local current_file = string.match(normalized_path, "^.*/(.+)$")
	vlc.msg.info("NXT:current_file:" , current_file)
    local next_file = nil
    local found_current = false

    for _, file in ipairs(files) do
		vlc.msg.dbg(file)
        if found_current then
            next_file = file
            break
        end
        if file == current_file then
            found_current = true
        end
    end

    if next_file then
        local next_uri = "file:///" .. folder_path .. "/" .. next_file
        vlc.playlist.clear()
        vlc.playlist.add({{path = next_uri}})
    end
end

function filter_media_files(files)
    local media_files = {}
    local media_extensions = {
        -- Videoformate
        "%.avi$", "%.mkv$", "%.mp4$", "%.wmv$", "%.flv%", 
        "%.mpeg$", "%.mpg$", "%.mov$", "%.rm$", "%.vob$", 
        "%.asf$", "%.divx$", "%.m4v$", "%.ogg$", "%.ogm$", 
        "%.ogv$", "%.qt$", "%.rmvb$", "%.webm$", "%.3gp$",
        "%.3g2$", "%.drc$", "%.f4v$", "%.f4p$", "%.f4a$", 
        "%.f4b$", "%.gifv$", "%.mng$", "%.mts$", "%.m2ts$", 
        "%.ts$", "%.mov$", "%.qt$", "%.mxf$", "%.nsv$", 
        "%.roq$", "%.svi$", "%.viv$",
        -- Audioformate
        "%.mp3$", "%.wav$", "%.flac$", "%.aac$", "%.ogg$", 
        "%.wma$", "%.alac$", "%.ape$", "%.ac3$", "%.opus$", 
        "%.aiff$", "%.aif$", "%.amr$", "%.au$", "%.mka$", 
        "%.dts$", "%.m4a$", "%.m4b$", "%.m4p$", "%.mpc$", 
        "%.mpp$", "%.mp+", "%.oga$", "%.spx$", "%.tta$",
        "%.voc$", "%.ra$", "%.mid$", "%.midi$"
    }

    for _, f in ipairs(files) do
        for _, ext in ipairs(media_extensions) do
            if string.match(f, ext) then
                table.insert(media_files, f)
                break
            end
        end
    end
    return media_files
end

