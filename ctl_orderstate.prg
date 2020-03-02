Define Class ctl_orderstate As ctl_public_sync_right Of ctl_public_sync_right.prg
    **��������Զ�������
     dal_orders = .F.
     dal_orderdetail = .F.
    

    Procedure Init
        DoDefault()
        This.dal_orders = Newobject("dal_orders","dal_orders.prg","",This.Datasource)               
        This.dal_orderdetail = Newobject("dal_orderdetail","dal_orderdetail.prg","",This.Datasource)    
    ENDPROC
    
    
    PROCEDURE getuser
	  Local lcPostData,oJson
        lcPostData = HttpGetPostData()
        oJson = foxjson_parse(lcPostData)
    	  cno = oJson.item("userno")
     	  cpwd = oJson.item("userpwd")
     	  
   	  TEXT TO lcSqlCmd NOSHOW textmerge
            SELECT username,password,departname,usertel FROM sellusers WHERE userno='<<cno>>' AND  password =  '<<cpwd>>'
        ENDTEXT
        *?lcsqlcmd
        
        **����MsSqlHelperʵ������ִ��sql���
        oDbHelper = NEWOBJECT("MsSqlHelper","MsSqlHelper.prg")
        IF oDbHelper.SqlQuery(lcSqlCmd,'sellusers') <0
            ERROR oDbHelper.errmsg
        ENDIF       

*!*	        TEXT TO cReturn NOSHOW TEXTMERGE PRETEXT 1+2
*!*		        {"errno":0,"errmsg":"OK","success":true}
*!*	        ENDTEXT
        Return cursortojson("sellusers")
    endproc
    
    
    PROCEDURE getorder
        Private ctj      
        cordertype = HttpQueryParams("orderstate")
        corderdesc = HttpQueryParams("orderdesc")
      	ctj = ''
        If (!EMPTY(cordertype))
        	TEXT TO ctj NOSHOW TEXTMERGE PRETEXT 1+2
                   where orderstate = '<<cordertype >>' and
        	ENDTEXT					        	
        ENDIF      
        If (!EMPTY(corderdesc))
        	IF EMPTY(ctj)
	        	TEXT TO ctj NOSHOW TEXTMERGE PRETEXT 1+2
	                    where orderdesc = '<<corderdesc>>' 
	        	ENDTEXT
        	ELSE
	        	TEXT TO ctj NOSHOW TEXTMERGE PRETEXT 1+2
	                  <<ctj>>  orderdesc = '<<corderdesc>>' and
	        	ENDTEXT
        	endif        	
        ENDIF      
        	
        TEXT TO ctj NOSHOW TEXTMERGE PRETEXT 1+2
	         SELECT * FROM view_orders <<ctj>>
        ENDTEXT
        *?ctj
        
        **��Ҫȥ�����һ��and
        ctj = LEFT(ctj,LEN(ctj)-3)

        oDbHelper = Newobject("MsSqlHelper","MsSqlHelper.prg")
        oDbHelper.SqlQuery(ctj,"view_orders")
        *nRow = oDbHelper.SqlSelectPage("cjxx",ctj,nPage,nLimit,"cjxx")

        *2019.9.9����dal_ca��������������䣨9.9ǰ��������䣩
        *nRow = oDbHelper.SqlSelectPage("View_hhxx",ctj,nPage,nLimit,"View_hhxx")

        *��������������Ҫ��ֻ����Ϊԭ����areaдΪ��aera,�����Ҳ���area�����·�ҳ���ɹ�
        *oDbHelper.sqlquery("SELECT * FROM orderdetail","ordertail")

        Return cursorToJson("view_orders")
    
    
    ENDPROC
    
    
    PROCEDURE getdetail
        Private ctj      
        corderno = HttpQueryParams("orderno")
      
        TEXT TO ctj NOSHOW TEXTMERGE PRETEXT 1+2
	         SELECT * FROM orderdetail WHERE orderno = '<<corderno>>'
        ENDTEXT

        oDbHelper = Newobject("MsSqlHelper","MsSqlHelper.prg")
        oDbHelper.SqlQuery(ctj,"orderdetail")
        Return cursorToJson("orderdetail")    
    endpro
    
    **�������Ĵ�����״̬��Ϊ�ѷ���״̬
    PROCEDURE changestate
    	PRIVATE cJson,oJson
    	corderno = HttpQueryParams("orderno")
    	?corderno
*!*	    	cJson = HttpGetPostData()
*!*	    	oJson = foxjson_parse(cJson)
*!*	    	corderno = oJson.item("orderno")
*!*	    	?'����',corderno
*!*	    	canc
    	
    	TEXT TO lcSql NOSHOW textmerge
    		UPDATE orders SET orderstate = '�ѷ���' WHERE orderno = '<<corderno>>'
    	ENDTEXT
    	*?lcSql
    	oDbHelper = Newobject("MsSqlHelper","MsSqlHelper.prg")
    	IF oDbHelper.SqlQuery(lcSql,"orders")
    		ERROR oDbHelper.errmsg
    	ENDIF 
    	TEXT TO cReturn NOSHOW TEXTMERGE PRETEXT 1+2
	        {"errno":0,"errmsg":"OK","success":true}
        ENDTEXT
        Return cReturn
    ENDPROC
    
	PROCEDURE export
		Private cJson,oJson
		cJson = HttpGetPostData()
		oJson = foxjson_parse(cJson)		

		**ǰ̨���ݹ���������
		corderdesc = oJson.Item("orderdesc")    &&
		ctj = ""

		oDbHelper = Newobject("MsSqlHelper","MsSqlHelper.prg")

		If (!Isnull(corderdesc ))
			TEXT TO ctj NOSHOW TEXTMERGE PRETEXT 1+2
	             SELECT * FROM view_orders where  orderdesc = '<<corderdesc >>'
			ENDTEXT
		Endif
			      
		*?ctj
		
*!*			oDbHelper = Newobject("MsSqlHelper","MsSqlHelper.prg")
*!*			TEXT TO ctj NOSHOW TEXTMERGE PRETEXT 1+2
*!*		             SELECT orderdate,departname,sellername,sellertel,receiver,recaddress,receivertel,orderstate,ordertype,orderdesc,manager,LTRIM(RTRIM(valuelist)) as valuelist FROM view_orders 
*!*				ENDTEXT
		
		nRow = oDbHelper.SQLQuery(ctj,"view_orders")				
        IF nRow<=0
        	RETURN  [{"errno":1,"errmsg":"û�б�������","success":false}]
        ENDIF 
        *COPY TO database/lsorder
        *replace m.name set memo�ֶ�  = cast(memo�ֶ� as c��120����
        *UPDATE database/lsorder SET valuelist = CAST(valuelist as c(50))
        *replace valuelist WITH CAST(valuelist as c(50))
        *SELECT lsorder
        *brow
		
		
	xx2=newobject("QiyuExcelEngine","QiyuExcelEngine.prg")
	xx2.ParseFile("orderreport.xml")	
	xx2.SetValue("˳���ʽ��ַ����","����")
	
	
	
	xx2.SetValue("view_orders") &&����һ����
	xx2.SetValue(DATETIME(),"ʱ��") &&����ʱ��
	
	**2019.10.30�����ԣ����ϲ�������,����������¿�����
	lcfilename=getWwwRootPath("")+SYS(2015)+".xls"
	*lcfilename=SYS(2015)+".xls"
	*lcfilename="down\"+Sys(2015)+".xls"
	xx2.Process()
	xx2.save(lcFilename)
	lcFilename = SUBSTR(lcFilename,6)
	
	TEXT TO cReturn NOSHOW TEXTMERGE 
	{"errno":0,"errmsg":"ok","file":"<<lcFilename>>"} 
	ENDTEXT 
	RETURN cReturn 	
	endproc    
    
    
    
    
	PROCEDURE save
		
        Local lcPostData,oJson
        lcPostData = HttpGetPostData()
       * _cliptext=lcPostData
        *?lcpostdata
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
        **�������µ�sql���
        TEXT TO lcSqlCmd NOSHOW textmerge
            INSERT INTO sellusers (userno,username,password,departname,usertel) VALUES  ('<<cno>>','<<cname>>','<<cpwd>>','<<cdepart>>','<<ctel>>')
        ENDTEXT
       * ?lcsqlcmd
        
        **����MsSqlHelperʵ������ִ��sql���
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
	
	
	***���涩����ϸ
	PROCEDURE saveorders
        Local lcPostData,oJson
        lcPostData = HttpGetPostData()    
        oJson = Createobject("foxjson")

        oJson.parse(lcPostData)

        x1 = oJson.Item("data").tostring()
        x2 = oJson.Item("rows").tostring()
        ?'����:',x1
        ?''
        ?'�ӱ�:',x2
        **�����ɱ������α�
        This.dal_orders.parseJson(x1,"",0)        
        this.dal_orderdetail.ParseJson(x2,"",0)
        **����SaveDatabase���Զ�ӵ���������
        If !This.SaveDatabase()
            Error This.msg
        Endif
        Local cReturn
        TEXT TO cReturn NOSHOW TEXTMERGE PRETEXT 1+2
	        {"errno":0,"errmsg":"OK","success":true}
        ENDTEXT
        Return cReturn
    ENDPROC	
	

    Procedure DoSave
        llReturn = .T.
        If !This.dal_orders.Save()
            Error "�޷�����"+Transform(This.dal_orders.msg)
        ENDIF
        If !This.dal_orderdetail.Save()
            Error "�޷�����"+Transform(This.dal_orderdetail.msg)
        Endif
        
        Return llReturn
    Endproc	
	

enddefin




