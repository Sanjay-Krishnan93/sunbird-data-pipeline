package org.ekstep.ep.samza.util;

import org.apache.samza.config.Config;
import java.util.ArrayList;
import java.util.List;

public class UserDataCache extends DataCache {

    public UserDataCache(Config config, LRUCache lruCache) {

        List defaultList = new ArrayList<String>();
        defaultList.add("usertype");
        defaultList.add("grade");
        defaultList.add("language");
        defaultList.add("subject");
        this.fieldsList = config.getList("user.metadata.fields", defaultList);
        this.lruCache = lruCache;
    }
}
