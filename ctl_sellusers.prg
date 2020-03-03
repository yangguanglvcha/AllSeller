Define Class ctl_sellusers As ctl_public_sync_right Of ctl_public_sync_right.prg
    **添加两个自定义属性
     dal_sellusers = .F.
    

    Procedure Init
        DoDefault()
        This.dal_sellusers = Newobject("dal_sellusers","dal_sellusers.prg","",This.Datasource)        
             	*-- 加载权限类 
 	  *oRight=NEWOBJECT("right_schedule","right_schedule.prg") 
 	  
    ENDPROC
    
    
    
	PROCEDURE save
		
        Local lcPostData,oJson
        lcPostData = HttpGetPostData()
       * _cliptext=lcPostData
       * ?lcpostdata
        *oJson = Createobject("foxjson")
        cno = HttpQueryParams("userno")
        cname = HttpQueryParams("username")
        cpwd = HttpQueryParams("newpwd")
        cdepart = HttpQueryParams("departname")
        ctel = HttpQueryParams("usertel")

        
*!*	         cno = oJson.item("userno")
*!*		   cname = oJson.item("username")
*!*		   cpwd = oJson.item("newpwd")
*!*		   cdepart = oJson.item("departname")
*!*		   ctel = oJson.item("usertel")
	*?cname,cdepart,ctel
        **构建更新的sql语句
        TEXT TO lcSqlCmd NOSHOW textmerge
            INSERT INTO sellusers (userno,username,password,departname,usertel) VALUES  ('<<cno>>','<<cname>>','<<cpwd>>','<<cdepart>>','<<ctel>>')
        ENDTEXT
       *?lcsqlcmd
        
        **创建MsSqlHelper实例，并执行sql语句
        oDbHelper = NEWOBJECT("MsSqlHelper","MsSqlHelper.prg")
        IF oDbHelper.SqlQuery(lcSqlCmd,'sellusers') <0
            ERROR oDbHelper.errmsg
        ENDIF       


        *userno=jh6701&username=%E7%9A%84%E7%9A%84&newpwd=111&conpwd=111&departname=%E5%8A%9E%E5%85%AC%E5%AE%A4&usertel=13061178181

        TEXT TO cReturn NOSHOW TEXTMERGE PRETEXT 1+2
	        {"errno":0,"errmsg":"OK","success":true}
        ENDTEXT
        Return cReturn
	
	ENDPROC
	

enddefin