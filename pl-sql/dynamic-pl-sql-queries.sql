
    PROCEDURE SEARCH_POLICY_IDS (
          P_START_YEAR    IN NUMBER,
          P_SEARCH_STRING IN VARCHAR2,
          P_ORDER_BY      IN VARCHAR2,
          o_data          OUT SYS_REFCURSOR  
    
    )AS
    
      v_select VARCHAR2(1000);
      v_from VARCHAR2(1000);
      v_where CLOB;
      v_order_by VARCHAR2(1000) := ' order by POLICY_ID ASC ';
      v_query CLOB;
    
    BEGIN 
    
      v_select := 'select pt.POLICY_ID, ' ||
                    ' pt.CREATOR_ID, ' ||
                    ' pt.CREATION_DATE, ' ||
                    ' pt.LAST_MODIFICATOR_ID, ' || 
                    ' pt.LAST_MODIFICATION_DATE ';
                    
      v_from := ' from POLICY_TAB pt ';
      
      v_where := ' where pt.STATUS = ' || CONSTANTS.STATUS_PUBLISHED || ' ';
      
      if P_START_YEAR is not null then
      
        v_where := v_where || ' and NVL(pt.START_YEAR, 0) >= ' || P_START_YEAR || ' ';
      
      end if;
      
      if P_SEARCH_STRING is not null then
      
        v_from := v_from || ', search_tab st ';
      
        v_where := v_where  || ' and st.content_type = ' || CONSTANTS.CONTENT_TYPE_POLICY ||
                               ' and st.content_id = pt.POLICY_ID ' ||
                               ' and contains(search_data, ''' || P_SEARCH_STRING || ''') > 0 ';
                               
      end if;
      
      if P_ORDER_BY is not null then
      
        v_order_by := ' order by ' || P_ORDER_BY || ' nulls last ';
      
      end if;
      
      v_query := v_select || v_from || v_where || v_order_by;
      
      open o_data for v_query;

    END SEARCH_POLICY_IDS ;

    PROCEDURE GET_UPCOMING_EVENT_IDS (   
           P_REF_DATE    IN VARCHAR2,
           P_STATUS      IN VARCHAR2,         
           P_PROJECT_IDS IN VARCHAR2,
           P_ORDER_BY    IN VARCHAR2,
           o_data        OUT SYS_REFCURSOR       
    ) AS
    
       v_type number;
   
    BEGIN 
        
       v_type := CONSTANTS.SEARCH_TYPE_EVENT ;
       
       
       /*USING end date to also include ongoing events*/
       
       
       if P_ORDER_BY IS NOT NULL then
      
          open o_data for ' select distinct et.EVENT_ID, 
                                    vipt.entity_id,
                                    et.CREATOR_ID,
                                    et.CREATION_DATE,
                                    et.LAST_MODIFICATOR_ID,
                                    et.LAST_MODIFICATION_DATE,
                                    et.STARTDATE
                            from    event_tab et,  
                                    VIEWABLE_IN_PROJECT_TAB vipt 
                            where   et.STATUS       in ( '||P_STATUS||')
                            and     et.endDate > to_date( '''||P_REF_DATE||''' , ''YYYY/MM/DD'' )
                            and     vipt.entity_type= '||v_type||'
                            and     vipt.entity_id  = et.EVENT_ID
                            and     vipt.project_ID in ('||P_PROJECT_IDS||')
                            order   by ' || P_ORDER_BY ; 
                  
       else
     
          open o_data for ' select distinct et.EVENT_ID, 
                                    vipt.entity_id,
                                    et.CREATOR_ID,
                                    et.CREATION_DATE,
                                    et.LAST_MODIFICATOR_ID,
                                    et.LAST_MODIFICATION_DATE,
                                    et.STARTDATE
                            from    event_tab et,  
                                    VIEWABLE_IN_PROJECT_TAB vipt 
                            where   et.STATUS       in ( '||P_STATUS||')
                            and     et.endDate > to_date('''||P_REF_DATE||''' , ''YYYY/MM/DD'' )
                            and     vipt.entity_type= '||v_type||'
                            and     vipt.entity_id  = et.EVENT_ID
                            and     vipt.project_ID in ('||P_PROJECT_IDS||')
                            order   by STARTDATE ASC ' ; 
          
        end if ;
     
    END GET_UPCOMING_EVENT_IDS ;