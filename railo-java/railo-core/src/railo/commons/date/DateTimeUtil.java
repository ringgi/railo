package railo.commons.date;

import java.util.Locale;
import java.util.TimeZone;

import railo.commons.lang.SystemOut;
import railo.runtime.engine.ThreadLocalPageContext;
import railo.runtime.exp.ExpressionException;
import railo.runtime.type.dt.DateTime;
import railo.runtime.type.dt.DateTimeImpl;

public abstract class DateTimeUtil {
	
    private static final double DAY_MILLIS = 86400000D;
	private static final long CF_UNIX_OFFSET = 2209161600000L;

	public static final int SECOND = 0;
	public static final int MINUTE = 1;
	public static final int HOUR = 2;
	public static final int DAY = 3;
	public static final int YEAR = 10;
	public static final int MONTH = 11;
	public static final int WEEK = 12;
	public static final int QUARTER = 20;
	public static final int MILLISECOND =30;
	
	
	
	private static DateTimeUtil instance;

	public static DateTimeUtil getInstance(){
		if(instance==null)	{
			// try to load Joda Date TimeUtil
			try{
				instance=new JREDateTimeUtil();
				SystemOut.printDate("using JRE Date Library");
			}
			// when not available (jar) load Impl that is based on the JRE
			catch(Throwable t){
				instance=new JREDateTimeUtil();
				SystemOut.printDate("using JRE Date Library");
			}
		}
		return instance;
	}

	public DateTime toDateTime(TimeZone tz,int year, int month, int day, int hour, int minute, int second, int milliSecond) throws DateTimeException {
		return new DateTimeImpl(toTime(tz,year, month, day, hour, minute, second,milliSecond),false);
	}
	
	public DateTime toDateTime(TimeZone tz,int year, int month, int day, int hour, int minute, int second, int milliSecond, DateTime defaultValue) {
		long time = toTime(tz,year, month, day, hour, minute, second,milliSecond,Long.MIN_VALUE);
		if(time==Long.MIN_VALUE) return defaultValue;
		return new DateTimeImpl(time,false);
	}	
	
	/**
     * returns a date time instance by a number, the conversion from the double to 
     * date is o the base of the coldfusion rules.
     * @param days double value to convert to a number
     * @return DateTime Instance
     */
    public DateTime toDateTime(double days) {
    	long utc=Math.round(days*DAY_MILLIS);
    	utc-=CF_UNIX_OFFSET;
    	utc-=getLocalTimeZoneOffset(utc);
    	return new DateTimeImpl(utc,false);
    }
	
	
	public long toTime(TimeZone tz,int year,int month,int day,int hour,int minute,int second,int milliSecond,long defaultValue){
		tz=ThreadLocalPageContext.getTimeZone(tz);
		year=toYear(year);
    	
        if(month<1)		return defaultValue;
        if(month>12)	return defaultValue;
        if(day<1) 		return defaultValue;
        if(hour<0) 		return defaultValue;
        if(minute<0) 	return defaultValue;
        if(second<0) 	return defaultValue;
        if(milliSecond<0) 	return defaultValue;
        if(hour>24) 	return defaultValue;
        if(minute>59) 	return defaultValue;
        if(second>59) 	return defaultValue;
        
        if(daysInMonth(year, month)<day) return defaultValue;
        
        return _toTime(tz, year, month, day, hour, minute, second, milliSecond);
	}

	public long toTime(TimeZone tz,int year,int month,int day,int hour,int minute,int second,int milliSecond) throws DateTimeException{
		tz=ThreadLocalPageContext.getTimeZone(tz);
		year=toYear(year);
    	
        if(month<1)		throw new DateTimeException("month number ["+month+"] must be at least 1");
        if(month>12)	throw new DateTimeException("month number ["+month+"] can not be greater than 12");
        if(day<1) 		throw new DateTimeException("day number ["+day+"] must be at least 1");
        if(hour<0) 		throw new DateTimeException("hour number ["+hour+"] must be at least 0");
        if(minute<0) 	throw new DateTimeException("minute number ["+minute+"] must be at least 0");
        if(second<0) 	throw new DateTimeException("second number ["+second+"] must be at least 0");
        if(milliSecond<0)throw new DateTimeException("milli second number ["+milliSecond+"] must be at least 0");
        
        if(hour>24) 	throw new DateTimeException("hour number ["+hour+"] can not be greater than 24");
        if(minute>59) 	throw new DateTimeException("minute number ["+minute+"] can not be greater than 59");
        if(second>59) 	throw new DateTimeException("second number ["+second+"] can not be greater than 59");
        
        if(daysInMonth(year, month)<day) 
        	throw new DateTimeException("day number ["+day+"] can not be greater than "+daysInMonth(year, month)+" when month is "+month+" and year "+year);
        
        return _toTime(tz, year, month, day, hour, minute, second, milliSecond);
	}
	
	/**
	 * return how much days given month in given year has
	 * @param year
	 * @param month
	 * @return
	 */
	public int daysInMonth(int year,int month){
		switch(month) {
	        case 1:
	        case 3:
	        case 5:
	        case 7:
	        case 8:
	        case 10:
	        case 12:
	        	return 31;
	        case 4:
	        case 6:
	        case 9:
		    case 11:
	        	return 30;
	        case 2:
	        	return isLeapYear(year)?29:28;
        }
		return -1;
	}
	
	/**
	 * translate 2 digit numbers to a year; for example 10 to 2010 or 50 to 1950
	 * @param year
	 * @return year matching number
	 */
	public int toYear(int year) {
		if(year<100) {
    	    if(year<30)year=year+=2000;
            else year=year+=1900;
        }
		return year;
	}
	
	/**
	 * return if given is is a leap year or not
	 * @param year
	 * @return is leap year
	 */
	public boolean isLeapYear(int year) {
		return ((year%4 == 0) && ((year%100 != 0) || (year%400 == 0)));
    }
	
	/**
     * cast boolean value
     * @param dateTime 
     * @return boolean value
     * @throws ExpressionException
     */
    public boolean toBooleanValue(DateTime dateTime) throws DateTimeException {
        throw new DateTimeException("can't cast Date ["+dateTime.toGMTString()+"] to boolean value");
    }
    
    public double toDoubleValue(DateTime dateTime) {
    	long utc = dateTime.getTime();
    	utc+=getLocalTimeZoneOffset	(utc);
    	utc+=CF_UNIX_OFFSET;
    	return utc/DAY_MILLIS;
    }
    
    private static long getLocalTimeZoneOffset(long utc){
    	return ThreadLocalPageContext.getTimeZone().getOffset(utc);
    }
    

	public long getMilliSecondsAdMidnight(TimeZone timeZone, long time) {
		return time-getMilliSecondsInDay(timeZone, time);
	}
    
    abstract long _toTime(TimeZone tz,int year,int month,int day,int hour,int minute,int second,int milliSecond);
	
	public abstract int getYear(TimeZone tz,railo.runtime.type.dt.DateTime dt);
	
	public abstract int getMonth(TimeZone tz,DateTime dt);
	
	public abstract int getDay(TimeZone tz,DateTime dt);

	public abstract int getHour(TimeZone tz,DateTime dt);
	
	public abstract int getMinute(TimeZone tz,DateTime dt);
	
	public abstract int getSecond(TimeZone tz,DateTime dt);
	
	public abstract int getMilliSecond(TimeZone tz,DateTime dt);

	public abstract long getMilliSecondsInDay(TimeZone tz, long time);
	
	public abstract int getDaysInMonth(TimeZone tz,DateTime dt);

	public abstract int getDayOfYear(Locale locale,TimeZone tz, DateTime dt);

	public abstract int getDayOfWeek(Locale locale,TimeZone tz, DateTime dt);

	public abstract int getWeekOfYear(Locale locale,TimeZone tz,DateTime dt);

	public abstract long getDiff(TimeZone tz, int datePart,DateTime left,DateTime right);

	public abstract String toString(DateTime dt, TimeZone tz);


}
