base_name=$(basename ${base})

case $base_name in
    deepin)
        sed -i "s#Update:.*#Update: $update_name#"   /mnt/mirror-snapshot/reprepro-base/deepin-2015-process/conf/distributions
        cd /mnt/mirror-snapshot/reprepro-base/deepin-2015-process;
        bash /mnt/mirror-snapshot/utils/checkupdate.sh
        ;;
    universe)
        sed -i "s#Update:.*#Update: $update_name#"   /srv/pool/base/universe/conf/distributions
        cd /srv/pool/base/universe ;
        bash /srv/pool/base/universe/checkupdate.sh
        ;;
    *)
        
        _date=$(date +%Y-%m-%d_%H:%M:%S)
        _check_log=/srv/pool/base/${base_name}/log/check-${_date}.log

        cd /srv/pool/base/${base_name}

        rpa_arch=$(/usr/bin/python3 getrpa.py ${rpa} ${rpa_codename} "Architectures")
        rpa_components=$(/usr/bin/python3 getrpa.py ${rpa} ${rpa_codename} "Components")

        rpa_name=$(basename ${rpa})

        # rewrite conf/updates
        mv conf/updates conf/updates.orig
        echo "Name: ${rpa_name}" > /srv/pool/base/${base_name}/conf/updates
        echo "Suite: ${rpa_codename}" >> /srv/pool/base/${base_name}/conf/updates
        echo "Architectures: ${rpa_arch} source" >> /srv/pool/base/${base_name}/conf/updates
        echo "Components: ${rpa_components}" >> /srv/pool/base/${base_name}/conf/updates
        echo "Method: ${rpa}" >> /srv/pool/base/${base_name}/conf/updates
        echo "VerifyRelease: blindtrust" >> /srv/pool/base/${base_name}/conf/updates

        sed -i "s#Update:.*#Update: ${rpa_name}#"  /srv/pool/base/${base_name}/conf/distributions

        cat /srv/pool/base/${base_name}/conf/distributions
        cat /srv/pool/base/${base_name}/conf/updates

        reprepro --noskipold --basedir /srv/pool/base/${base_name} --outdir /srv/pool/www/${base_name} checkupdate | tee  ${_check_log}
        /usr/bin/python3 /srv/pool/base/${base_name}/log2json.py ${_check_log}
        mkdir -p /srv/pool/www/${base_name}/checkupdate/${review_id}
        cp  /srv/pool/base/${base_name}/index.html /srv/pool/www/${base_name}/checkupdate/${review_id}/
        mv /srv/pool/base/${base_name}/*.json /srv/pool/www/${base_name}/checkupdate/${review_id}/result.json

        mv conf/updates.orig conf/updates  
        ;;
esac