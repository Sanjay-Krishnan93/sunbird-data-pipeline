package org.ekstep.ep.samza.util;

import org.apache.samza.config.Config;
import java.util.ArrayList;
import java.util.List;

public class DialCodeDataCache extends DataCache {

    public DialCodeDataCache(Config config, LRUCache lruCache) {

        List defaultList = new ArrayList<String>();
        defaultList.add("identifier");
        defaultList.add("channel");
        defaultList.add("batchcode");
        defaultList.add("publisher");
        defaultList.add("generated_on");
        defaultList.add("published_on");
        defaultList.add("status");
        this.fieldsList = config.getList("dialcode.metadata.fields", defaultList);
        this.lruCache = lruCache;
    }
}
