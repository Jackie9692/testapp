package com.tj.sse.service.serviceImpl;

import java.util.List;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Service;

import com.tj.sse.bo.Student;
import com.tj.sse.dao.StudentDao;
import com.tj.sse.model.Person;
import com.tj.sse.service.NameService;

@Service
public class NameServiceImpl implements NameService, ApplicationContextAware{
	private ApplicationContext applicationContext;
	@Autowired(required=false)
	private StudentDao studentDao;
	public void setStudentDao(StudentDao studentDao) {
		this.studentDao = studentDao;
	}

	@Override
	public Person getPerson(int id) {
		Person person = new Person("Jackie", 23, "Shanghai");
		return person;
	}

	@Override
	public void setApplicationContext(ApplicationContext applicationContext)
			throws BeansException {
		this.applicationContext = applicationContext;
	}

	@Override
	public void save() {
		System.out.println(applicationContext.getBean("studentDao").hashCode());
		System.out.println(applicationContext.getBean("sessionFactory").hashCode());
		System.out.println("haha");
	}

	@Override
	public List<Student> findList() {
		return studentDao.findList();
	}

}
