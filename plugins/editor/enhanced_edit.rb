author      'Daniel Mendler'
description 'Enhanced edit form with preview and diff'
dependencies 'engine/engine'

class Wiki::Application
  hook(:before_edit_form_buttons) do
    %{<input type="checkbox" name="minor" id="minor" value="1"#{params[:minor] ? ' checked="checked"' : ''}/>
      <label for="minor">#{:minor_changes.t}</label><br/>
      <button type="submit" name="preview" accesskey="p">#{:preview.t}</button>
      <button type="submit" name="changes" accesskey="c">#{:changes.t}</button>}.unindent
  end

  hook(:before_edit_form) do
    if @preview
      %{<div class="preview">#{@preview}</div>}
    elsif @patch
      format_changes(@patch)
    end
  end

  hook(:before_page_save) do |page|
    if (action?(:new) || action?(:edit)) && params[:content]
      if params[:preview]
        flash.error :empty_commit_message.t if params[:message].blank? && !params[:minor]

        if page.mime.text?
          if params[:pos]
            # We assume that engine stays the same if section is edited
            engine = Engine.find!(page, :layout => true)
            page.content = params[:content]
          else
            # Whole page edited, assign new content before engine search
            page.content = params[:content]
            engine = Engine.find!(page, :layout => true)
          end
          @context = Context.new(:app => self, :resource => page, :logger => logger)
          @preview = engine.render(@context) if engine
        end

        halt haml(request.put? ? :edit : :new)
      elsif params[:changes]
        flash.error :empty_commit_message.t if params[:message].blank? && !params[:minor]

        original = Tempfile.new('original')
        original.write(page.content(params[:pos], params[:len]))
        original.close

        new = Tempfile.new('new')
        new.write(params[:content].gsub("\r\n", "\n"))
        new.close

        # Read in binary mode and fix encoding afterwards
        @patch = IO.popen("diff -u '#{original.path}' '#{new.path}'", 'rb') {|io| io.read }
        @patch.force_encoding(__ENCODING__)

	halt haml(request.put? ? :edit : :new)
      else
        params[:message] = :minor_changes.t if params[:minor] && params[:message].blank?
      end
    end
  end
end
