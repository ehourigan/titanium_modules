/**
 * Ti.StyledLabel Module
 * Copyright (c) 2010-2013 by Appcelerator, Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

package ti.styledlabel;

import java.util.HashMap;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;
import org.ccil.cowan.tagsoup.Parser;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiMessenger;
import org.appcelerator.kroll.common.AsyncResult;

import ti.styledlabel.parsing.CustomImageGetter;
import ti.styledlabel.parsing.CustomLinkMovementMethod;
import ti.styledlabel.parsing.HtmlParser;
import ti.styledlabel.parsing.HtmlToSpannedConverter;

import android.graphics.Color;
import android.text.InputType;
import android.view.Gravity;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;
import android.os.Handler;
import android.os.Message;
import android.text.Spanned;

public class Label extends TiUIView {

	private String _html;
	private String[] _filteredTags;
	private int _filterTagsMode = -1;
	private TiViewProxy pr;

	public Label(TiViewProxy proxy) {
		super(proxy);

		WebView webview = new WebView(TiApplication.getAppCurrentActivity().getApplicationContext());
		webview.getSettings().setJavaScriptEnabled(true);
		webview.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
		webview.getSettings().setAllowContentAccess(true);
		webview.setBackgroundColor(0x00000000);
		pr = proxy;
		webview.setWebViewClient(new WebViewClient(){
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url){
				if(url.startsWith("blankify://")) {
					HashMap<String, String> hashMap= new HashMap<String, String>();
					hashMap.put("data", url.replaceAll("blankify://", ""));
					pr.fireEvent("blankify.answer.updated", hashMap);
					return true;
				}
				else if(url.startsWith("selected://")) {
					HashMap<String, String> hashMap= new HashMap<String, String>();
					hashMap.put("data", url.replaceAll("selected://", ""));
					pr.fireEvent("blankify.answer.selected", hashMap);
					return true;
				}
			    return false; 
			}
		});
		setNativeView(webview);
	}

	@Override
	public void processProperties(KrollDict props) {
		super.processProperties(props);
		if (props.containsKey("html")) {
			setHtml(props.getString("html"));
		}
		if (props.containsKey("filteredTags")) {
			setFilteredTags(props.getStringArray("filteredTags"));
		}
		if (props.containsKey("filteredTagsMode")) {
			setFilteredTagsMode(props.getInt("filteredTagsMode"));
		}
	}

    private static final int MSG_UPDATE_TEXT = 50000;

    private final Handler handler = new Handler(TiMessenger.getMainMessenger().getLooper(), new Handler.Callback ()
	{
    	public boolean handleMessage(Message msg)
        {
            switch (msg.what) {
                case MSG_UPDATE_TEXT: {
                    AsyncResult result = (AsyncResult) msg.obj;
                    handleUpdateText((String) result.getArg());
                    result.setResult(null);
                    return true;
                }
            }
            return false;
        }
	});

  	private void updateText(final String html)
  	{
  	    if (!TiApplication.isUIThread()) {
  	        TiMessenger.sendBlockingMainMessage(handler.obtainMessage(MSG_UPDATE_TEXT), html);
  	    } else {
  	        handleUpdateText(html);
  	    }
  	}

  	
  	private void handleUpdateText(final String html){
  		WebView webview = (WebView) getNativeView();
  		webview.loadDataWithBaseURL(null, html, "text/html", "utf-8", null);

  	}

	public void setHtml(String html) {
		_html = html;
		Parser parser = new Parser();
		try {
			parser.setProperty(Parser.schemaProperty, HtmlParser.schema);
		} catch (org.xml.sax.SAXNotRecognizedException e) {
			// Should not happen.
			throw new RuntimeException(e);
		} catch (org.xml.sax.SAXNotSupportedException e) {
			// Should not happen.
			throw new RuntimeException(e);
		}


        updateText(_html);
	}

	public void setFilteredTags(String[] tags) {
		_filteredTags = tags;
		if (_filteredTags != null && _filterTagsMode != -1) {
			setHtml(_html);
		}
	}

	public void setFilteredTagsMode(int mode) {
		_filterTagsMode = mode;
		if (_filteredTags != null && _filterTagsMode != -1) {
			setHtml(_html);
		}
	}
}
