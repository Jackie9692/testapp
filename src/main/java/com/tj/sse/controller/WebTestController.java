package com.tj.sse.controller;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping("/test")
public class WebTestController {
	private String name;
	@RequestMapping(value="/threadSafety", method=RequestMethod.GET)
	public String testThread(HttpServletRequest request, HttpServletResponse response) throws IOException{
		name = request.getParameter("name");
		request.setAttribute("time", new Date().toString());
		request.setAttribute("name", name);
		System.out.println("name" + name);
		try{
			Thread.sleep(10000);
		}catch (InterruptedException e) {
			System.out.println("你好，" + name + ", 使用了get提交数据");
		}
		return "test";
	}
}
