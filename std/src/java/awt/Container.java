package java.awt;

import java.util.*;
import java.awt.peer.ContainerPeer;

public class Container {

	protected List<Component> childs = new ArrayList<Component>();
	protected LayoutManager lm;

	public Container() {}

	public int getComponentCount() {
		return childs.size();
	}

	public void addNotify() {
		if (peer == null) {
			peer = new ContainerPeer();
		}
		for (Component child : childs) {
			if (!child.isDisplayable()) {
				child.addNotify();
			}
		}
	}

	public Component getComponent(int n) {
		if (n < 0 || n > childs.size()) {
			throw new ArrayIndexOutOfBoundsException();
		}
		return childs.get(n);
	}

	public Component[] getComponents() {
		return childs.toArray(new Component[childs.size()]);
	}

	public Component add(Component comp) {
		addImpl(comp, null, -1);
	}

	public Component add(Component comp, int index) {
		addImpl(comp, null, index);
	}

	public Component add(String name, Component comp) {
		addImpl(comp, name, -1);
	}

	public Component add(Component comp, Object constraints) {
		addImpl(comp, constraints, -1);
	}

	public Component add(Component comp, Object constraints, int index) {
		addImpl(comp, constraints, index);
	}

	public void remove(int index) {
		childs.remove(index);
	}

	public void remove(Component comp) {
		childs.remove(comp);
	}

	public void removeAll() {
		for (Component comp : childs) {
			remove(comp);
		}
	}

	public LayoutManager getLayout() {
		return lm;
	}

	public void setLayout(LayoutManager lm) {
		this.lm = lm;
	}

	public void doLayout() {
		if (lm != null) {
			lm.layoutContainer(this);
		}
	}

	public void validate() {
		synchronized (getTreeLock()) {
			if (!valid) {
				doLayout();
				validateTree();
				valid = true;
			}
		}
	}

	protected void validateTree() {
		for (Component comp : childs) {
			comp.validate();
		}
	}

	protected void addImpl(Component comp, Object constraints, int index) {
		synchronized (getTreeLock()) {
			if (comp.getParent() != null) {
				comp.getParent().remove(comp);
			}

			if (index == -1) {
				childs.add(comp);
			} else {
				childs.add(index, comp);
			}

			if (peer != null && visible) {
				comp.addNotify();
			}
			if (comp.peer != null) {
				comp.peer.setParent((ContainerPeer) peer);
			}

			comp.invalidate();
			comp.parent = this;
		}
	}

}
