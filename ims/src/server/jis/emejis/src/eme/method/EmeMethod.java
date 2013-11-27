package eme.method;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.SQLException;

import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;

import net.sf.json.JSONException;
 
import eme.EmeBusinessException;
import eme.EmeContext;
import eme.JisContext;

public class EmeMethod {
	private Method m = null;
	private Object classob = null;
	private boolean readonly = true;
	
	
	

	public Method getM() {
		return m;
	}




	public void setM(Method m) {
		this.m = m;
	}




	public Object getClassob() {
		return classob;
	}




	public void setClassob(Object classob) {
		this.classob = classob;
	}




	public boolean isReadonly() {
		return readonly;
	}




	public void setReadonly(boolean readonly) {
		this.readonly = readonly;
	}




	public Object invoke(JisContext c) throws JSONException, SQLException,
			InvocationTargetException, IllegalAccessException {
		Connection conn = c.getDb().getConn();
		try {
			 
			if (!readonly) {
				conn.setAutoCommit(false);
			}

			Object ob = m.invoke(classob, c);

			if (!readonly) {
				conn.commit();
			}

			conn.close();
			return ob;

		} catch (InvocationTargetException e) {
			if (e.getCause() instanceof JSONException) {
				// e.printStackTrace();
				throw new JSONException();
			}
			if (e.getCause() instanceof SQLException) {
				// e.printStackTrace();
				throw new SQLException();

			} else {
				// e.printStackTrace();
				throw e;

			}
		}

		finally {

			if (conn != null) {
				if (!readonly) {
					conn.rollback();
				}
				conn.close();
			}

		}

	}
	

	public Object emeinvoke(JisContext c) throws JSONException, SQLException,
			InvocationTargetException, IllegalAccessException ,IOException,EmeBusinessException{
	 
		SqlSession session=null;
		try {
			SqlSessionFactory mybatisFactory=	EmeContext.getMybatisFactory();
			
			 
				session=mybatisFactory.openSession(readonly);
						
			 
                c.setSession(session);
         
			Object ob = m.invoke(classob, c);

			if (!readonly) {
				session.commit();
			}

			session.close();
			return ob;

		} catch (InvocationTargetException e) {
			
	 
			
			if (e.getCause() instanceof EmeBusinessException) {
				  e.printStackTrace();
				throw new EmeBusinessException(e.getTargetException().getMessage());
			}
			if (e.getCause() instanceof JSONException) {
				  e.printStackTrace();
				throw new JSONException();
			}
			if (e.getCause() instanceof SQLException) {
				 e.printStackTrace();
				throw new SQLException();

			} else {
				  e.printStackTrace();
				throw e;

			}
		}

		finally {

			if (session != null) {
				if (!readonly) {
					session.rollback();
				}
				session.close();
			}

		}

	}

}
