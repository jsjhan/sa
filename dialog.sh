#!/bin/sh
show_url () {
    page=$1
    content=$(w3m -dump "$1")
    if [ -z $page ] || [ -z $content ];then
        dialog --title "$Browser" --msgbox 'page not found' 200 200
    else
        dialog --title "$Browser" --msgbox "$content" 200 200
    fi
}
homepage=www.google.com
Browser="my Browser"
term=$(cat ~/.mybrowser/useterm)
dialog --title "terms and Conditions of Use" --yesno "$term" 200 200
out=$?

if [ $out -eq 1 ];then
    dialog --title "Apology" --ok-label QQ --msgbox "goodbye" 200 200
fi


if [ $out -eq 0 ];then
    page=$homepage
    content=$(w3m -dump "$page")
    dialog --title "$Browser" --msgbox "$content" 200 200
    while [ 1 ]
        do
            if [ -z $page ];then
                page=$homepage
            fi
            input=$(dialog --inputbox "$page" 200 200 --output-fd 1)
            out=$?
            if [ $out -eq 1 ];then
                break
            fi

            #parse command or url
            if [ "$(echo $input | head -c 1)" = "/" ];then
                pre=${input#/}

                #/S or /source
                if [ "$pre" = "S" ] || [ "$pre" = "source" ];then
                    dialog --title "$Browser" --msgbox "$(curl -s -L "$page")" 200 200
                fi

                #/L or /link
                if [ "$pre" = "L" ] || [ "$pre" = "link" ];then
                    cmd="<a href=\".*[^\"]"
                    url=$(curl -s -L "$page" |grep -o "$cmd" | cut -d '"' -f 2)
                    urls=''
                    if [ "$(echo -n $page | tail -c 1)" = "/" ];then
                        page=${page%%/}
                    fi
                    oldifs=$IFS
                    IFS=$'\n'
                    for word in $url;do
                        if [ "$(echo $word | head -c 1)" = "/" ];then
                            if [ ${#urls}  -eq 0 ];then
                                urls=$page$word
                            else
                                urls=$urls$'\n'$page$word
                            fi
                        else
                            if [ "$(echo $word | head -c 4 )" = "http" ];then
                                if [ ${#urls}  -eq 0 ];then
                                    urls=$word
                                else
                                    urls=$urls$'\n'$word
                                fi
                            else
                                if [ ${#urls}  -eq 0 ];then
                                    urls=$page'/'$word
                                else
                                    urls=$urls$'\n'$page'/'$word
                                fi
                            fi
                        fi
                    done

                    links="$( echo "$urls" | awk '{printf("%d;%s;", NR, $0)}')"
                    IFS=$';'
                    res="$( dialog --title "$Browser" --menu "Links"  200  200  150 $links  --output-fd 1 )"
                    IFS=$oldifs
                    out=$?
                    if [ $out -eq 1 ];then
                        continue
                    fi
                    cmd=";$res;[^;]*[^;]"

                    show_url $(echo "$links" | grep -o "$cmd" | cut -d ';' -f 3 )
                    
                fi

                #/D or /download
                if [ "$pre" = "D" ] || [ "$pre" = "download" ];then
                    cmd="<a href=\".*[^\"]"
                    url=$(curl -s -L "$page" |grep -o "$cmd" | cut -d '"' -f 2)
                    urls=''
                    if [ "$(echo -n $page | tail -c 1)" = "/" ];then
                        page=${page%%/}
                    fi
                    oldifs=$IFS
                    IFS=$'\n'
                    for word in $url;do
                        if [ "$(echo $word | head -c 1)" = "/" ];then
                            if [ ${#urls}  -eq 0 ];then
                                urls=$page$word
                            else
                                urls=$urls$'\n'$page$word
                            fi
                        else
                            if [ "$(echo $word | head -c 4 )" = "http" ];then
                                if [ ${#urls}  -eq 0 ];then
                                    urls=$word
                                else
                                    urls=$urls$'\n'$word
                                fi
                            else
                                if [ ${#urls}  -eq 0 ];then
                                    urls=$page'/'$word
                                else
                                    urls=$urls$'\n'$page'/'$word
                                fi
                            fi
                        fi
                    done

                    links="$( echo "$urls" | awk '{printf("%d;%s;", NR, $0)}')"
                    IFS=$';'
                    res="$( dialog --title "$Browser" --menu "Links"  200  200  150 $links  --output-fd 1 )"
                    IFS=$oldifs
                    out=$?
                    if [ $out -eq 1 ];then
                        continue
                    fi
                    cmd=";$res;[^;]*[^;]"
                    dir=$HOME"/Downloads"
                    if [ ! -d "$dir" ]; then
                        mkdir -p "$dir"
                    fi
                    wget -c -b -q -P ~/Downloads/ $(echo "$links" | grep -o "$cmd" | cut -d ';' -f 3 )
                fi

                #/B or /bookmark
                if [ "$pre" = "B" ] || [ "$pre" = "bookmark" ];then
                    bookmark="$(printf 'Add_a_bookmark\nDelete_a_bookmark\n' |cat - ~/.mybrowser/bookmark | awk '{printf("%10d %s ", NR, $0)}')"
                    res="$(dialog --title "$Browser" --menu "Bookmarks" 200 200 150 $bookmark --output-fd 1)"
                    out=$?
                    if [ $out -eq 1 ];then
                        continue
                    fi
                    if [ $res -eq 1 ];then
                        input2=$(dialog --inputbox "Add bookmark" 200 200 --output-fd 1)
                        echo "$input2" >> ~/.mybrowser/bookmark
                        
                    elif [ $res -eq 2 ];then
                        bookmark="$(cat ~/.mybrowser/bookmark | awk '{printf("%10d %s ", NR, $0)}')"
                        input2="$(dialog --title "$Browser" --menu "Delete bookmark" 200 200 150 $bookmark --output-fd 1)"
                        input2=$input2"d"
                        sed -i '' "$input2" ~/.mybrowser/bookmark
                    else
                        cmd=" $res [^ ]*[^ ]"
                        show_url $(echo "$bookmark" | grep -o "$cmd"| cut -d ' ' -f 3 )
                    fi
                fi

                #/H or /help
                if [ "$pre" = "H" ] || [ "$pre" = "help" ];then
                    help=$(cat ~/.mybrowser/help)
                    dialog --title "$Browser" --msgbox "$help" 200 200
                fi
            elif [ "$(echo $input | head -c 1)" = "!" ];then
                pre=${input#!}
                cmd_output=$("$pre")
                dialog --title "$Browser" --msgbox "$cmd_output" 200 200
            else
                show_url $input
            fi
        done
fi

