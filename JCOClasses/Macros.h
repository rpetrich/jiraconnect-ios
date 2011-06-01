//
//  Macros.h
//  JIRA_Connect
//
//  Created by Stefan Saasen on 01.06.11.
//  Copyright 2011 Atlassian. All rights reserved.
//

#define JCOLocalizedString(key, comment) \
    [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"JCOLocalizable"]
