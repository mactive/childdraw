//
//  LogEventConstants.h
//  jiemo
//
//  Created by Xiaosi Li on 12/12/12.
//  Copyright (c) 2012 oyeah. All rights reserved.
//

#ifndef jiemo_LogEventConstants_h
#define jiemo_LogEventConstants_h

#define EVENT_ABOUT_US      @"E_about_us"
#define EVENT_ADD_FRIEND    @"E_add_friend"
#define EVENT_DEL_FRIEND    @"E_del_friend"
#define EVENT_LOGIN_TIMER   @"E_login_timer"
#define EVENT_ENTER_BACKGROUND  @"E_enter_background"
#define EVENT_ENTER_FOREGROUND  @"E_enter_foreground"

#define EVENT_READING_TIMER             @"E_step_reading_timer"
#define EVENT_READING_FINISH_TIMER      @"E_step_finish_timer"
#define EVENT_PHOTO                     @"E_photo_picture"
#define EVENT_SHARE                     @"E_share_weixin"

//define reading time and read click
#define EVENT_CHANNEL_TIMER     @"E_reading_timer"
#define EVENT_ARTICLE_READ      @"E_article_read"
#define EVENT_ARTICLE_TIMER     @"E_article_timer"

#define EVENT_CHANNEL_UNREAD    @"E_channel_unread"
#define EVENT_CHANNEL_READ      @"E_channel_read"


//define all timer variables
#define TIMER_GET_NEARBY_USER   @"T_nearby_user"
#define TIMER_UPDATE_IDENTITY   @"T_get_identity"

// define all additional 
#define PAGE_LOGIN          @"A_page_login"
#define PAGE_WELCOME        @"A_page_welcome"
#define PAGE_LOGIN_SETTING  @"A_page_login_setting"
#define PAGE_NEARBY_USER    @"A_page_nearby_user"
#define PAGE_CONVERSATION   @"A_page_conversation"
#define PAGE_MESSAGE        @"A_page_message"
#define PAGE_CONTACT_LIST   @"A_page_contact_list"
#define PAGE_CONTACT_DETAIL @"A_page_contact_detail"
#define PAGE_SETTINGS       @"A_page_settings"

#endif
