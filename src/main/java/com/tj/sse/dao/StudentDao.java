package com.tj.sse.dao;

import java.util.List;

import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.tj.base.dao.BaseDao;
import com.tj.sse.bo.Student;


@Repository
@Transactional(readOnly = false)
public class StudentDao extends BaseDao{
	public List<Student> findList() {
		String hql = "select ss from Student ss where 1 = 1";
		List<Student> boList = this.find(hql);
		
		return boList;
	}

}






