package com.tj.sse.service;

import java.util.List;

import com.tj.sse.bo.Student;
import com.tj.sse.model.Person;

public interface NameService {
	public List<Student> findList();
	public Person getPerson(int id);
	public void save();
}
